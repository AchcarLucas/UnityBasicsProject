using System;
using UnityEngine;

using UnityEngine.Rendering.PostProcessing;

public class PostProcessOutlineRenderer : PostProcessEffectRenderer<PostProcessOutline>
{
    public static RenderTexture outlineRendererTexture;

    public override DepthTextureMode GetCameraFlags() {
        return DepthTextureMode.Depth;
    }

    public override void Render(PostProcessRenderContext context) {
        PropertySheet sheet = context.propertySheets.Get(Shader.Find("Unlit/OutlineHLSL"));

        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_MinDepth", settings.depthMin);
        sheet.properties.SetFloat("_MaxDepth", settings.depthMax);
        sheet.properties.SetColor("_OutlineColor", settings.outlineColor);

        if( outlineRendererTexture == null || 
            outlineRendererTexture.width != Screen.width ||
            outlineRendererTexture.height != Screen.height) {
                outlineRendererTexture = new RenderTexture(Screen.width, Screen.height, 24);
                context.camera.targetTexture = outlineRendererTexture;
            }

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
