using UnityEngine;
using System.Linq;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;

namespace UnityEditor.Rendering.Universal
{
    class SerializedUniversalRenderPipelineGlobalSettings
    {
        public SerializedObject serializedObject;
        private List<UniversalRenderPipelineGlobalSettings> serializedSettings = new List<UniversalRenderPipelineGlobalSettings>();

        public SerializedProperty lightLayerName0;
        public SerializedProperty lightLayerName1;
        public SerializedProperty lightLayerName2;
        public SerializedProperty lightLayerName3;
        public SerializedProperty lightLayerName4;
        public SerializedProperty lightLayerName5;
        public SerializedProperty lightLayerName6;
        public SerializedProperty lightLayerName7;
        public SerializedProperty renderingLayerName8;
        public SerializedProperty renderingLayerName9;
        public SerializedProperty renderingLayerName10;
        public SerializedProperty renderingLayerName11;
        public SerializedProperty renderingLayerName12;
        public SerializedProperty renderingLayerName13;
        public SerializedProperty renderingLayerName14;
        public SerializedProperty renderingLayerName15;
        public SerializedProperty renderingLayerName16;
        public SerializedProperty renderingLayerName17;
        public SerializedProperty renderingLayerName18;
        public SerializedProperty renderingLayerName19;
        public SerializedProperty renderingLayerName20;
        public SerializedProperty renderingLayerName21;
        public SerializedProperty renderingLayerName22;
        public SerializedProperty renderingLayerName23;
        public SerializedProperty renderingLayerName24;
        public SerializedProperty renderingLayerName25;
        public SerializedProperty renderingLayerName26;
        public SerializedProperty renderingLayerName27;
        public SerializedProperty renderingLayerName28;
        public SerializedProperty renderingLayerName29;
        public SerializedProperty renderingLayerName30;
        public SerializedProperty renderingLayerName31;

        public SerializedProperty stripDebugVariants;
        public SerializedProperty stripUnusedPostProcessingVariants;
        public SerializedProperty stripUnusedVariants;

        public SerializedUniversalRenderPipelineGlobalSettings(SerializedObject serializedObject)
        {
            this.serializedObject = serializedObject;

            // do the cast only once
            foreach (var currentSetting in serializedObject.targetObjects)
            {
                if (currentSetting is UniversalRenderPipelineGlobalSettings urpSettings)
                    serializedSettings.Add(urpSettings);
                else
                    throw new System.Exception($"Target object has an invalid object, objects must be of type {typeof(UniversalRenderPipelineGlobalSettings)}");
            }


            lightLayerName0 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName0);
            lightLayerName1 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName1);
            lightLayerName2 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName2);
            lightLayerName3 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName3);
            lightLayerName4 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName4);
            lightLayerName5 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName5);
            lightLayerName6 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName6);
            lightLayerName7 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.lightLayerName7);
            renderingLayerName8 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName8);
            renderingLayerName9 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName9);
            renderingLayerName10 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName10);
            renderingLayerName11 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName11);
            renderingLayerName12 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName12);
            renderingLayerName13 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName13);
            renderingLayerName14 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName14);
            renderingLayerName15 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName15);
            renderingLayerName16 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName16);
            renderingLayerName17 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName17);
            renderingLayerName18 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName18);
            renderingLayerName19 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName19);
            renderingLayerName20 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName20);
            renderingLayerName21 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName21);
            renderingLayerName22 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName22);
            renderingLayerName23 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName23);
            renderingLayerName24 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName24);
            renderingLayerName25 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName25);
            renderingLayerName26 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName26);
            renderingLayerName27 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName27);
            renderingLayerName28 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName28);
            renderingLayerName29 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName29);
            renderingLayerName30 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName30);
            renderingLayerName31 = serializedObject.Find((UniversalRenderPipelineGlobalSettings s) => s.renderingLayerName31);

            stripDebugVariants = serializedObject.FindProperty("m_StripDebugVariants");
            stripUnusedPostProcessingVariants = serializedObject.FindProperty("m_StripUnusedPostProcessingVariants");
            stripUnusedVariants = serializedObject.FindProperty("m_StripUnusedVariants");
        }
    }
}
