#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN

#tryinclude <basecomm>
#tryinclude <materialadmin>

#define REQUIRE_PLUGIN

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Chat Logging",
	description = "Logs all server chat (and all administrator messages)",
	author = "R1KO",
	version = "3.0",
	url = "https://github.com/R1KO/Chat-Logging"
}

#define SZF(%0) 	%0, sizeof(%0)

Database g_hDatabase;
bool g_bIsLog[10];
int g_iServerID;
bool g_bHasMaterialadmin = false;
bool g_bHasBasecomm = false;

static const char g_szMessages[][] = {
	"say", 
	"say_team", 
	"sm_say", 
	"sm_chat", 
	"sm_csay", 
	"sm_tsay", 
	"sm_msay", 
	"sm_hsay", 
	"sm_psay"};

static const char g_szConVars[][] = {
	"sm_chat_log_triggers",
	"sm_chat_log_say", 
	"sm_chat_log_say_team",
	"sm_chat_log_sm_say", 
	"sm_chat_log_chat",
	"sm_chat_log_csay",
	"sm_chat_log_tsay",
	"sm_chat_log_msay",
	"sm_chat_log_hsay",
	"sm_chat_log_psay"
};

static const char g_szTable[] = "chatlog";

public void OnPluginStart()
{
	if (!SQL_CheckConfig("chatlog"))
	{
		SetFailState("[CHAT LOG] Database failure: Could not find Database conf \"chatlog\"");
		return;
	}

	Database.Connect(SQL_OnConnect, "chatlog");

	char szDesc[][] = {
		"Logging Chat Triggers", 
		"Logging General Chat",
		"Logging to the Team Chat Log", 
		"Logging the command sm_say", 
		"Logging the command sm_chat", 
		"Logging the command sm_csay", 
		"Logging the command sm_tsay", 
		"Logging the command sm_msay", 
		"Logging the command sm_hsay", 
		"Logging the command sm_psay"
	};

	ConVar hCvar;
	
	hCvar = CreateConVar("sm_chat_log_server_id", "1", "Server ID");
	
	hCvar.AddChangeHook(OnServerIdChange);
	
	g_iServerID = hCvar.IntValue;

	for (int i = 0; i < sizeof(g_szConVars); ++i)
	{
		hCvar = CreateConVar(g_szConVars[i], "1", szDesc[i], _, true, 0.0, true, 1.0);
		hCvar.AddChangeHook(OnLogConVarChange);
		g_bIsLog[i] = true;
	}

	AutoExecConfig(true, "chat_logging");

	for (int i = 0; i < sizeof(g_szMessages); ++i)
	{
		AddCommandListener(Say_Callback, g_szMessages[i]);
	}
}

public void OnServerIdChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_iServerID = hCvar.IntValue;
}

public void OnLogConVarChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{ 
	char szName[32];
	GetConVarName(hCvar, SZF(szName));

	for (int i = 0; i < sizeof(g_szConVars); ++i)
	{
		if (!strcmp(g_szConVars[i], szName))
		{
			g_bIsLog[i] = hCvar.BoolValue;
			return;
		}
	}
}

public Action Say_Callback(int iClient, const char[] szCommand, int args)
{
	if (g_hDatabase && iClient > 0 && IsClientInGame(iClient))
	{
		if (IsChatTrigger() && !g_bIsLog[0])
		{
			return Plugin_Continue;
		}

		// LogMessage("Say_Callback: IsEnabledType(%s): %b", szCommand, IsEnabledType(szCommand));
		if (!IsEnabledType(szCommand))
		{
			return Plugin_Continue;
		}

		if (IsChatMessage(szCommand) && IsClientGagged(iClient))
		{
			return Plugin_Handled;
		}

		char szText[192];
		GetCmdArgString(SZF(szText));
		TrimString(szText);
		StripQuotes(szText);

		if (!szText[0])
		{
			return Plugin_Handled;
		}
		// LogMessage("Say_Callback: szText: '%s'", szText);

		char szQuery[512], szMessage[512], szName[MAX_NAME_LENGTH*2+1], szAuth[32], szIP[16];

		GetClientName(iClient, SZF(szAuth));
		GetClientIP(iClient, SZF(szIP));
		g_hDatabase.Escape(szAuth, SZF(szName));
		GetClientAuthId(iClient, AuthId_Steam2, SZF(szAuth));
		g_hDatabase.Escape(szText, SZF(szMessage));

		FormatEx(SZF(szQuery), "INSERT INTO `%s` (\
			`server_id`, `auth`, `ip`, `name`, `team`, `alive`, `timestamp`, `type`, `message`) VALUES \
			(%d, '%s', '%s', '%s', %d, %b, %d, '%s', '%s');", 
			g_szTable, g_iServerID, szAuth, szIP, szName, GetClientTeam(iClient), IsPlayerAlive(iClient), GetTime(), szCommand, szMessage);

		// LogMessage("Say_Callback: szQuery: '%s'", szQuery);
		g_hDatabase.Query(SQL_ErrorCallback, szQuery);
	}	
	return Plugin_Continue;
}

bool IsClientGagged(int iClient)
{
	if (g_bHasBasecomm)
	{
		return BaseComm_IsClientGagged(iClient);
	}

	if (g_bHasMaterialadmin)
	{
		return MAGetClientMuteType(iClient) > 1;
	}
	return false;
}

public void SQL_ErrorCallback(Database hDatabase, DBResultSet hResults, const char[] szError, any iData)
{
	if (!hDatabase || szError[0])
	{
		LogError("[CHAT LOG] Fail SQL_ErrorCallback: %s", szError);
	}
}

bool IsEnabledType(const char[] szMsgType)
{
	for (int i = 0; i < sizeof(g_szMessages); ++i)
	{
		if (!strcmp(szMsgType, g_szMessages[i]))
		{
			return g_bIsLog[i];
		}
	}
	return false;
}

bool IsChatMessage(const char[] szMsgType)
{
	return !strcmp(szMsgType, g_szMessages[1]) || !strcmp(szMsgType, g_szMessages[2]);
}

public void SQL_OnConnect(Database hDatabase, const char[] sError, any data)
{
	if (hDatabase == null)
	{
		SetFailState("[CHAT LOG] Failed to connect to database (%s)", sError);
		return;
	}

	g_hDatabase = hDatabase;

	char sQuery[1024];

	FormatEx(SZF(sQuery), "CREATE TABLE IF NOT EXISTS `%s` (\
								`msg_id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, \
								`server_id` INT UNSIGNED NOT NULL, \
								`auth` VARCHAR(32) NOT NULL, \
								`ip` VARCHAR(16) NOT NULL, \
								`name` VARCHAR(65) NOT NULL, \
								`team` TINYINT NOT NULL, \
								`alive` TINYINT NOT NULL, \
								`timestamp` INT UNSIGNED NOT NULL, \
								`message` VARCHAR(255) NOT NULL, \
								`type` VARCHAR(16) NOT NULL\
							) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;", g_szTable);

	g_hDatabase.Query(SQL_ErrorCallback, sQuery);

	SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8mb4'");
	SQL_FastQuery(g_hDatabase, "SET CHARSET 'utf8mb4'");

	g_hDatabase.SetCharset("utf8mb4");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bHasMaterialadmin = LibraryExists("materialadmin");
	g_bHasBasecomm = LibraryExists("basecomm");

	#if defined _materialadmin_included
	MarkNativeAsOptional("MAGetClientMuteType");
	#endif
	
	#if defined _basecomm_included
	MarkNativeAsOptional("BaseComm_IsClientGagged");
	#endif

	return APLRes_Success;
}

public void OnLibraryAdded(const char[] szName)
{
	#if defined _steamtools_included
	if(!strcmp(szName, "materialadmin", false))
	{
		g_bHasMaterialadmin = true;
	}
	#endif
	
	#if defined _basecomm_included
	if(!strcmp(szName, "basecomm", false))
	{
		g_bHasBasecomm = true;
	}
	#endif
}

public void OnLibraryRemoved(const char[] szName)
{
	#if defined _steamtools_included
	if(!strcmp(szName, "materialadmin", false))
	{
		g_bHasMaterialadmin = false;
	}
	#endif

	#if defined _basecomm_included
	if(!strcmp(szName, "basecomm", false))
	{
		g_bHasBasecomm = false;
	}
	#endif
}
