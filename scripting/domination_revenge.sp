#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sourcecolors>

public Plugin myinfo =
{
	name = "Domination & Revenge",
	author = "Ilusion9",
	description = "Domination and revenge.",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

ConVar g_Cvar_DominationKills;
EngineVersion g_EngineVesion;

int g_ConsecutiveKills[MAXPLAYERS + 1][MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("domination_revenge.phrases");
	
	g_EngineVesion = GetEngineVersion();
	g_Cvar_DominationKills = CreateConVar("sm_domination_kills", "5", "After how many consecutive kills players are dominating?", FCVAR_NONE, true, 0.0);
	
	HookEvent("player_death", Event_PlayerDeath_Pre, EventHookMode_Pre);
}

public void OnConfigsExecuted()
{
	SetConVar("sv_nonemesis", "1");
}

public void OnClientConnected(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_ConsecutiveKills[client][i] = 0;
		g_ConsecutiveKills[i][client] = 0;
	}
}

public void Event_PlayerDeath_Pre(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_Cvar_DominationKills.BoolValue)
	{
		return;
	}
	
	int client = GetClientOfUserId(event.GetInt("userid"));	
	if (!client || !IsClientInGame(client))
	{
		return;
	}
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (!attacker || attacker == client || !IsClientInGame(attacker))
	{
		return;
	}
	
	bool takingRevenge = g_ConsecutiveKills[client][attacker] >= g_Cvar_DominationKills.IntValue;
	g_ConsecutiveKills[client][attacker] = 0;
	g_ConsecutiveKills[attacker][client]++;
	
	if (takingRevenge)
	{
		if (g_EngineVesion == Engine_CSS 
			|| g_EngineVesion == Engine_CSGO 
			|| g_EngineVesion == Engine_DODS)
		{
			event.SetBool("revenge", true);
		}
		
		CPrintToChat(attacker, "%t", "You Took Revenge", client);
		CPrintToChat(client, "%t", "Has Taken Revenge", attacker);
	}
	else
	{
		if (g_ConsecutiveKills[attacker][client] < g_Cvar_DominationKills.IntValue)
		{
			return;
		}
		
		if (g_EngineVesion == Engine_CSS 
			|| g_EngineVesion == Engine_CSGO 
			|| g_EngineVesion == Engine_DODS)
		{
			event.SetBool("dominated", true);
		}
		
		if (g_ConsecutiveKills[attacker][client] == g_Cvar_DominationKills.IntValue)
		{
			CPrintToChat(client, "%t", "Is Dominating You", attacker);
			CPrintToChat(attacker, "%t", "You Are Dominating", client);
		}
		else
		{
			CPrintToChat(client, "%t", "Is Still Dominating You", attacker);
			CPrintToChat(attacker, "%t", "You Are Still Dominating", client);
		}
	}
}

void SetConVar(const char[] cvarName, const char[] value)
{
	ConVar cvar = FindConVar(cvarName);
	if (cvar)
	{
		cvar.SetString(value);
	}
}
