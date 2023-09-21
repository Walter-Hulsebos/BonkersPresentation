NGSSEB or Next-Gen Screen-Space Edge-Bevel is a camera command buffer effect that smooth the look of geometry edges.
Perfect for detached geometry such as CAD or ArchViz models or any model that requires a real-time soldering touch.

Highlights:
- Super optimized and fast, adjustable quality levels
- Per material masking using stencil buffer
- Smooth look, perfect for scenes composed of models that need this edgy attached/soldering look
- Plug and play, does not require any asset modification, just drag the script to your main camera and voila
- Compatible with any built-in shader (custom or not), works only with deferred rendering
- AR/VR/XR single-pass and multi-pass supported

Install:
- Just drag the script to your main camera and tweak the properties to suit your project quality needs

Material Masking:
- To remove NGSSEB effect per material, use the provided shaders: "Standard No NGSSEB" or "Standard No NGSSEB (Specular setup)"
- If you have custom shaders and you want to remove the NGSSEB effect on those materials add this stencil function anywhere in your shader inside the SubShader block (but outside the CGPROGRAM block):

	Stencil
	{
		Ref 10
		Comp Always
		Pass replace
	}

Masking Note:
If you are already using the stencil value of 10 for other stencil effects, you can change the NGSSEB shaders stencil compare values to something else.


Important:
- Does not work with Forward rendering
- If you are targeting mobile don't go crazy with the Quality, recommended on powerful devices that runs deferred rendering fine

Future:
- Improvements to the algorithm (better edge detection)
- Per-pixel masking using unused Gbuffer channels
- SRP ports (HDRP and URP planned for late 2020)

Support:
Email: support@psychozinteractive.com
Discord: https://discord.gg/AXJGzsm