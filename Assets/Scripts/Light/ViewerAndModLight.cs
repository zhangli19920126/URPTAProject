using System;
using DG.Tweening;
using UnityEngine;


namespace SpaceX {
    [ExecuteInEditMode]
    [DefaultExecutionOrder(601)]
    //1.光照方向取决于相机视角和角色朝向
    //2.模型正向摄像机时， 模型转动时，灯光缓动保证打向人脸
    //3.旋转到模型背面时，把背面当做正面，重复第二条
    public class ViewerAndModLight : MonoBehaviour {

        public static ViewerAndModLight Get(GameObject go)
        {
            var comp = go.GetComponent<ViewerAndModLight>();
            if(comp == null)
                comp = go.AddComponent<ViewerAndModLight>();
            return comp;
        }

        [SerializeField] private Transform mCameraTransform;
        [SerializeField] private Transform mModTransform;
        [SerializeField] private float speed = 8f;
        [SerializeField] private float speedRatio = 0.2f;
        [SerializeField] private float yPos = -0.1f;
        
        private Tweener mTween;
        private float mLerpValue;
        
        private void LateUpdate()
        {
            if (mCameraTransform == null || mModTransform == null) return;
            
            var lightTargetDir = CalculateLightTarget();
            RotateLight(lightTargetDir);
        }

        private void RotateLight(Vector3 modDir)
        {
            var tagert = new Vector3(modDir.x, yPos, modDir.z);
            var ratio = speed + Vector3.Distance(tagert,  transform.forward)* speedRatio;
            
            mLerpValue = ratio * Time.deltaTime;
            transform.forward = Vector3.Lerp (transform.forward, tagert, ratio * Time.deltaTime);
            
            if (mLerpValue > 0.999)
            {
                mLerpValue = 1;
                transform.forward = tagert;
            }
        }

        /// <summary>
        /// 计算目标方向
        /// </summary>
        /// <returns></returns>
        private Vector3 CalculateLightTarget()
        {
            var cameraDir = mCameraTransform.forward.ProjectOntoPlane(Vector3.up);
            var modDir = mModTransform.forward.ProjectOntoPlane(Vector3.up);
            var angle = Vector3.SignedAngle(cameraDir, modDir, Vector3.up);

            if (angle > 0 && angle < 90)//右背面，相机右侧垂直轴作为反射轴，计算背面对称向量；反射过程已经相当于取了一次反，不用再次取反
            {
                var reflect = Quaternion.AngleAxis(90, Vector3.up) * cameraDir;
                modDir = Vector3.Reflect(modDir, reflect);
            }
            else if (angle < 0 && angle > -90)//左背面，相机左侧垂直轴作为反射轴
            {
                var reflect = Quaternion.AngleAxis(-90, Vector3.up) * cameraDir;
                modDir = Vector3.Reflect(modDir, reflect);
            }
            else //正面情况时，直接取反
            {
                modDir *= -1;
            }

            return modDir;
        }

        /// <summary>
        /// 目标相机
        /// </summary>
        public void SetCamera(GameObject go)
        {
            mCameraTransform = go ? go.transform : null;
        }

        /// <summary>
        /// 目标模型
        /// </summary>
        public void SetMod(GameObject go)
        {
            mModTransform = go ? go.transform : null;
        }

        /// <summary>
        /// 灯光Y轴倾斜成度， -1到1之间
        /// </summary>
        public void SetYInclination(float inclination)
        {
            yPos = inclination;
        }

        /// <summary>
        /// 速率和衰减率
        /// </summary>
        public void SetSpeed(float speed, float speedRatio)
        {
            this.speed = speed;
            this.speedRatio = speedRatio;
        }
        
        
    }
}