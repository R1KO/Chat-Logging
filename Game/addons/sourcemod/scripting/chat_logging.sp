#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <basecomm>

#if SOURCEMOD_V_MINOR > 7
#pragma newdecls required
#endif

#if SOURCEMOD_V_MINOR > 7
Database g_hDatabase;
bool g_bIsLog[10];
ConVar g_hServerID;

static const char g_sSay[][] = {"say", "say_team", "sm_say", "sm_chat", "sm_csay", "sm_tsay", "sm_msay", "sm_hsay", "sm_psay"};
static const char g_sTable[] = "chatlog";

public Plugin myinfo = 
#else
new Handle:g_hDatabase;
new bool:g_bIsLog[10];
new Handle:g_hServerID;

new const String:g_sSay[][] = {"say", "say_team", "sm_say", "sm_chat", "sm_csay", "sm_tsay", "sm_msay", "sm_hsay", "sm_psay"};
new const String:g_sTable[] = "chatlog";

public Plugin:myinfo = 
#endif
{
	name = "Chat Logging",
	author = "R1KO",
	version = "2.3"
}

#define SZF(%0) 	%0, sizeof(%0)

#if SOURCEMOD_V_MINOR > 7
public void OnPluginStart()
#else
public OnPluginStart()
#endif
{
	g_hServerID = CreateConVar("sm_chat_log_server_id", "1", "ID сервера");

	#if SOURCEMOD_V_MINOR > 7
	ConVar hCvar;
	#else
	decl Handle:hCvar;
	#endif

	RegConVar(hCvar, "sm_chat_log_triggers", "0", "Запись в лог чат-триггеров", OnLogTriggersChange, 9);
	RegConVar(hCvar, "sm_chat_log_say", "1", "Запись в лог общего чата", OnLogSayChange, 0);
	RegConVar(hCvar, "sm_chat_log_say_team", "1", "Запись в лог командного чата", OnLogSayTeamChange, 1);
	RegConVar(hCvar, "sm_chat_log_sm_say", "1", "Запись в лог команды sm_say", OnLogSmSayChange, 2);
	RegConVar(hCvar, "sm_chat_log_chat", "1", "Запись в лог команды sm_chat", OnLogChatChange, 3);
	RegConVar(hCvar, "sm_chat_log_csay", "1", "Запись в лог команды sm_csay", OnLogCSayChange, 4);
	RegConVar(hCvar, "sm_chat_log_tsay", "1", "Запись в лог команды sm_tsay", OnLogTSayChange, 5);
	RegConVar(hCvar, "sm_chat_log_msay", "1", "Запись в лог команды sm_msay", OnLogMSayChange, 6);
	RegConVar(hCvar, "sm_chat_log_hsay", "1", "Запись в лог команды sm_hsay", OnLogHSayChange, 7);
	RegConVar(hCvar, "sm_chat_log_psay", "1", "Запись в лог команды sm_psay", OnLogPSayChange, 8);
	
	AutoExecConfig(true, "chat_logging");

	#if SOURCEMOD_V_MINOR > 7
	for(int i = 0; i < sizeof(g_sSay); ++i)
	#else
	for(new i = 0; i < sizeof(g_sSay); ++i)
	#endif
	{
		AddCommandListener(Say_Callback, g_sSay[i]);
	}

	if(!SQL_CheckConfig("chatlog"))
	{
		SetFailState("[CHAT LOG] Database failure: Could not find Database conf \"chatlog\"");
		return;
	}
	#if SOURCEMOD_V_MINOR > 7
	Database.Connect(SQL_OnConnect, "chatlog");
	#else
	SQL_TConnect(SQL_OnConnect, "chatlog");
	#endif
}

#if SOURCEMOD_V_MINOR > 7
void RegConVar(ConVar &hCvar, const char[] sCvar, const char[] sDefValue, const char[] sDesc, ConVarChanged callback, int index)
{
	hCvar = CreateConVar(sCvar, sDefValue, sDesc, _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(callback);
	g_bIsLog[index] = hCvar.BoolValue;
}

public void OnLogTriggersChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[9] = GetConVarBool(hCvar); }
public void OnLogSayChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[0] = GetConVarBool(hCvar); }
public void OnLogSayTeamChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[1] = GetConVarBool(hCvar); }
public void OnLogSmSayChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[2] = GetConVarBool(hCvar); }
public void OnLogChatChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[3] = GetConVarBool(hCvar); }
public void OnLogCSayChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[4] = GetConVarBool(hCvar); }
public void OnLogTSayChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[5] = GetConVarBool(hCvar); }
public void OnLogMSayChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[6] = GetConVarBool(hCvar); }
public void OnLogHSayChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[7] = GetConVarBool(hCvar); }
public void OnLogPSayChange(ConVar hCvar, const char[] oldValue, const char[] newValue) { g_bIsLog[8] = GetConVarBool(hCvar); }
#else
RegConVar(&Handle:hCvar, const String:sCvar[], const String:sDefValue[], const String:sDesc[], ConVarChanged:callback, index)
{
	hCvar = CreateConVar(sCvar, sDefValue, sDesc, _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, callback);
	g_bIsLog[index] = GetConVarBool(hCvar);
}

public OnLogTriggersChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[9] = GetConVarBool(hCvar);
public OnLogSayChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[0] = GetConVarBool(hCvar);
public OnLogSayTeamChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[1] = GetConVarBool(hCvar);
public OnLogSmSayChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[2] = GetConVarBool(hCvar);
public OnLogChatChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[3] = GetConVarBool(hCvar);
public OnLogCSayChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[4] = GetConVarBool(hCvar);
public OnLogTSayChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[5] = GetConVarBool(hCvar);
public OnLogMSayChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[6] = GetConVarBool(hCvar);
public OnLogHSayChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[7] = GetConVarBool(hCvar);
public OnLogPSayChange(Handle:hCvar, const String:oldValue[], const String:newValue[]) g_bIsLog[8] = GetConVarBool(hCvar);
#endif

#if SOURCEMOD_V_MINOR > 7
public Action Say_Callback(int iClient, const char[] sCommand, int args)
#else
public Action:Say_Callback(iClient, const String:sCommand[], args)
#endif
{
	if(!g_hDatabase)
	{
		return Plugin_Continue;
	}

	if(iClient > 0 && IsClientInGame(iClient))
	{
		#if SOURCEMOD_V_MINOR > 7
		char sText[192];
		#else
		decl String:sText[192];
		#endif
		GetCmdArgString(SZF(sText));
		if((IsChatTrigger() && g_bIsLog[9]) || !IsChatTrigger())
		{
			#if SOURCEMOD_V_MINOR > 7
			for(int i = 0; i < sizeof(g_sSay); ++i)
			#else
			for(new i = 0; i < sizeof(g_sSay); ++i)
			#endif
			{
				if(strcmp(sCommand, g_sSay[i]) == 0 && g_bIsLog[i])
				{
					if(i < 2 && BaseComm_IsClientGagged(iClient))
					{
						return Plugin_Handled;
					}

					#if SOURCEMOD_V_MINOR >= 7
					DBStatement hStmt;
					
					char sError[256], sName[MAX_NAME_LENGTH], sAuth[32], sIP[16], sQuery[256];

					GetClientAuthId(iClient, AuthId_Steam2, SZF(sAuth));
					int iServerID = g_hServerID.IntValue;
					#else
					decl Handle:hStmt, String:sError[256], String:sName[MAX_NAME_LENGTH], String:sAuth[32], String:sIP[16], String:sQuery[256], iServerID;

					GetClientAuthString(iClient, SZF(sAuth));
					iServerID = GetConVarInt(g_hServerID);
					#endif

					GetClientName(iClient, SZF(sName));
					GetClientIP(iClient, SZF(sIP));

					TrimString(sText);
					StripQuotes(sText);

					FormatEx(SZF(sQuery), "INSERT INTO `%s` (`server_id`, `auth`, `ip`, `name`, `team`, `alive`, `timestamp`, `type`, `message`) VALUES (%i, '%s', '%s', ?, %i, %b, %i, '%s', ?);", g_sTable, iServerID, sAuth, sIP, GetClientTeam(iClient), IsPlayerAlive(iClient), GetTime(), sCommand);

					hStmt = SQL_PrepareQuery(g_hDatabase, sQuery, SZF(sError));
					#if SOURCEMOD_V_MINOR > 7
					if (hStmt != null)
					#else
					if (hStmt != INVALID_HANDLE)
					#endif
					{
						#if SOURCEMOD_V_MINOR > 7
						hStmt.BindString(0, sName, false);	
						hStmt.BindString(1, sText, false);
						#else
						SQL_BindParamString(hStmt, 0, sName, false);	
						SQL_BindParamString(hStmt, 1, sText, false);
						#endif

						if (!SQL_Execute(hStmt))
						{
							SQL_GetError(hStmt, SZF(sError));
							LogError("[CHAT LOG] Fail SQL_Execute: %s", sError);
						}
					}
					else
					{
						LogError("[CHAT LOG] Fail SQL_PrepareQuery: %s", sError);
					}

					#if SOURCEMOD_V_MINOR > 7
					delete hStmt;
					#else
					CloseHandle(hStmt);
					#endif
					
					return Plugin_Continue;
				}
			}
		}
	}
	
	return Plugin_Continue;
}

#if SOURCEMOD_V_MINOR > 7
public void SQL_CheckError(Database hDB, DBResultSet hResults, const char[] sError, any data)
#else
public SQL_CheckError(Handle:hDB, Handle:hResults, const String:sError[], any:data)
#endif
{
	if(sError[0]) LogError("[CHAT LOG] Query Failed: %s", sError);
}

#if SOURCEMOD_V_MINOR > 7
public void SQL_OnConnect(Database hDatabase, const char[] sError, any data)
#else
public SQL_OnConnect(Handle:hDriver, Handle:hDatabase, const String:sError[], any:data)
#endif
{
	#if SOURCEMOD_V_MINOR > 7
	if (hDatabase == null)
	#else
	if (hDatabase == INVALID_HANDLE)
	#endif
	{
		SetFailState("[CHAT LOG] Не удалось подключиться к базе данных (%s)", sError);
		return;
	}
	else
	{
		g_hDatabase = hDatabase;

		SQL_LockDatabase(g_hDatabase);
		#if SOURCEMOD_V_MINOR > 7
		char sQuery[1024];
		#else
		decl String:sQuery[1024];
		#endif

		FormatEx(SZF(sQuery), "CREATE TABLE IF NOT EXISTS `%s` (\
												`msg_id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, \
												`server_id` INT UNSIGNED NOT NULL, \
												`auth` VARCHAR(65) NOT NULL, \
												`ip` VARCHAR(65) NOT NULL, \
												`name` VARCHAR(65) NOT NULL, \
												`team` TINYINT NOT NULL, \
												`alive` TINYINT NOT NULL, \
												`timestamp` INT UNSIGNED NOT NULL, \
												`message` VARCHAR(255) NOT NULL, \
												`type` VARCHAR(16) NOT NULL\
												) CHARACTER SET utf8 COLLATE utf8_general_ci;", g_sTable);
		#if SOURCEMOD_V_MINOR > 7
		g_hDatabase.Query(SQL_CheckError, sQuery);
		#else
		SQL_TQuery(g_hDatabase, SQL_CheckError, sQuery);
		#endif
		SQL_UnlockDatabase(g_hDatabase);

		SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8'");
		SQL_FastQuery(g_hDatabase, "SET CHARSET 'utf8'");

		#if SOURCEMOD_V_MINOR > 7
		g_hDatabase.SetCharset("utf8");
		#else
		SQL_SetCharset(g_hDatabase, "utf8");
		#endif
	}
}