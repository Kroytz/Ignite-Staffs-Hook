#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <dhooks>
#include <sdkhooks>
#include <laper32>

Handle g_hIgniteEntity = INVALID_HANDLE;
Handle g_hExtinguishEntity = INVALID_HANDLE;

GlobalForward g_hOnIgniteEntity;
GlobalForward g_hOnExtinguishEntity;

public Plugin myinfo =
{
    name        = "Fire Staff Hook",
    author      = "Kroytz",
    description = "Hook ignite and extinguish",
    version     = "1.0",
    url         = ""
};

public void OnPluginStart()
{
    // Gamedata.
    Handle hConfig = LoadGameConfigFile("sdktools.games\\engine.csgo");
    if (hConfig == INVALID_HANDLE)
        SetFailState("Why no gamedata??");

    int igniteOffset = GameConfGetOffset(hConfig, "Ignite");
    if (igniteOffset == -1)
        SetFailState("Failed to find Ignite offset");

    int extinguishOffset = GameConfGetOffset(hConfig, "Extinguish");
    if (extinguishOffset == -1)
        SetFailState("Failed to find Extinguish offset");

    CloseHandle(hConfig);

    // Ignite( float flFlameLifetime, bool bNPCOnly, float flSize, bool bCalledByLevelDesigner )
    g_hIgniteEntity = DHookCreate(igniteOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, Hook_Ignite);
    DHookAddParam(g_hIgniteEntity, HookParamType_Float);
    DHookAddParam(g_hIgniteEntity, HookParamType_Bool);
    DHookAddParam(g_hIgniteEntity, HookParamType_Float);
    DHookAddParam(g_hIgniteEntity, HookParamType_Bool);

    // Extinguish()
    g_hExtinguishEntity = DHookCreate(extinguishOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, Hook_Extinguish);
}

public void OnClientPostAdminCheck(int client)
{
    DHookEntity(g_hIgniteEntity, false, client);
    DHookEntity(g_hExtinguishEntity, false, client);
}

public MRESReturn Hook_Ignite(int entity, Handle hParams)
{
    // 不存在的玩家, 不管.
    if (!IsPlayerExist(entity))
        return MRES_Ignored;

    float time = view_as<float>(DHookGetParam(hParams, 1));
    PrintToChatAll("Triggered Ignite Hook with player %d, length: %.2f", entity, time);

    return MRES_Supercede;
}

public MRESReturn Hook_Extinguish(int entity, Handle hParams)
{
    // 不存在的玩家, 不管.
    if (!IsPlayerExist(entity))
        return MRES_Ignored;

    PrintToChatAll("Triggered Extinguish Hook with player %d", entity);
    return MRES_Supercede;
}