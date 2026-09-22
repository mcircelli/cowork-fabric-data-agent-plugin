# LuxMoto Seguros Fabric Data Agent plugin

This package connects Microsoft 365 Copilot Cowork directly to the LuxMoto Seguros Fabric Data Agent MCP endpoint. The Data Agent is grounded in the Fabric IQ ontology and does not require the custom Node.js MCP bridge.

The package includes an agent skill that teaches Cowork when to use the connector, how to apply insurance filters, and how to format ontology-grounded results.

## Configuration

The manifest targets:

| Setting | Value |
|---|---|
| Workspace ID | `d15dc07d-3e17-457a-9346-3b3dae156262` |
| Data Agent ID | `9400461b-ecc3-4108-b7ad-bd3152f82a00` |
| MCP host | `api.fabric.microsoft.com` |
| MCP tool | `DataAgent_Data_Agent_Fabric_LuxMotoSeguros` |
| Authentication | Microsoft Entra delegated OAuth through `OAuthPluginVault` |

The Data Agent MCP server doesn't support Dynamic Client Registration. The manifest uses `OAuthPluginVault` with the OAuth client registration ID created in the tenant that hosts the Data Agent. The user signs in with a Microsoft Entra account and retains their existing Fabric permissions.

## Package the plugin

Run:

```powershell
.\package.ps1
```

The script creates:

```text
build\luxmoto-data-agent-cowork-plugin.zip
```

The packaging script writes explicit relative ZIP entry names with `/` separators. It rejects absolute paths, backslashes, and parent-directory references.

The ZIP contains only the files required by Cowork:

```text
manifest.json
toolDescription.json
color.png
outline.png
skills/
  luxmoto-seguros/
    SKILL.md
```

The v1.28 manifest schema and Cowork package validator require `mcpToolDescription` with a non-empty `tools` array. The packaged descriptor uses the exact tool name published by the Data Agent.

The skill improves routing and orchestration. It does not replace MCP connectivity. If the Fabric endpoint doesn't return tools after authentication, the skill reports that the data source is unavailable instead of creating an ungrounded answer.

## Install in Cowork

1. Open Microsoft 365 Copilot Cowork.
2. Open **Customize**, then **Plugins**.
3. Select **Add plugin**.
4. Upload `build\luxmoto-data-agent-cowork-plugin.zip`.
5. Publish and enable the plugin.
6. Complete the Microsoft Entra sign-in prompt.

The signed-in user must have permission to access the Fabric workspace and ontology item.

## Troubleshooting

If Cowork doesn't start an OAuth flow, verify that the OAuth client registration exists in the same Microsoft 365 tenant as the Data Agent, allows the plugin manifest ID, and requests the Fabric scope.

Do not change the connector to `"type": "None"`. The Fabric Data Agent MCP endpoint requires Microsoft Entra authentication.
