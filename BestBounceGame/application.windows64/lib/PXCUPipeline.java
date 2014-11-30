/*******************************************************************************

INTEL CORPORATION PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with Intel Corporation and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2012-2013 Intel Corporation. All Rights Reserved.

*******************************************************************************/
package intel.pcsdk;

import intel.pcsdk.*;
import processing.core.*;
import java.nio.*; 

public class PXCUPipeline extends PXCUPipelineJNI {
	private PApplet parent;

	public PXCUPipeline(PApplet parent) {    
		super();
		this.parent = parent;
		parent.registerDispose(this);
	}  

	public boolean QueryRGB(PImage rgbImage) {
		if (rgbImage==null) return false;
		rgbImage.loadPixels();
		boolean sts=QueryRGB(rgbImage.pixels);
		rgbImage.updatePixels();
		return sts;
	}
  
	public boolean QueryLabelMapAsImage(PImage data) {
		if (data==null) return false;
		byte[] labelMap=new byte[data.width*data.height];
		int[] labels=new int[3];
		if (!QueryLabelMap(labelMap,labels)) return false;
		data.loadPixels();
		for (int i=0;i<labelMap.length;i++)
			data.pixels[i]=(0xff<<24)+(labelMap[i]<<16)+(labelMap[i]<<8)+(labelMap[i]);
		data.updatePixels();
		return true;
	}

    public boolean ProjectImageToRealWorld(PVector[] pos2d, PVector[] pos3d) {
		PXCMPoint3DF32[] p2d=new PXCMPoint3DF32[pos2d.length];
		for (int i=0;i<pos2d.length;i++)
			p2d[i]=new PXCMPoint3DF32(pos2d[i].x,pos2d[i].y,pos2d[i].z);

		PXCMPoint3DF32[] p3d=new PXCMPoint3DF32[pos3d.length];
		boolean sts=ProjectImageToRealWorld(p2d,p3d);
		if (sts) {
			for (int i=0;i<pos3d.length;i++)
				pos3d[i]=new PVector(p3d[i].x,p3d[i].y,p3d[i].z);
		}
		return sts;
    }

    public boolean ProjectRealWorldToImage(PVector[] pos3d, PVector[] pos2d) {
		PXCMPoint3DF32[] p3d=new PXCMPoint3DF32[pos3d.length];
		for (int i=0;i<pos3d.length;i++)
			p3d[i]=new PXCMPoint3DF32(pos3d[i].x,pos3d[i].y,pos3d[i].z);

		PXCMPointF32[] p2d=new PXCMPointF32[pos2d.length];
		boolean sts=ProjectRealWorldToImage(p3d,p2d);
		if (sts) {
			for (int i=0;i<pos2d.length;i++)
				pos2d[i]=new PVector(p2d[i].x,p2d[i].y);
		}
		return sts;
    }

    public boolean MapDepthToColorCoordinates(PVector[] pos3d, PVector[] posc) {
		PXCMPoint3DF32[] p3d=new PXCMPoint3DF32[pos3d.length];
		for (int i=0;i<pos3d.length;i++)
			p3d[i]=new PXCMPoint3DF32(pos3d[i].x,pos3d[i].y,pos3d[i].z);

		PXCMPointF32[] pc=new PXCMPointF32[posc.length];
		boolean sts=MapDepthToColorCoordinates(p3d,pc);
		if (sts) {
			for (int i=0;i<posc.length;i++)
				posc[i]=new PVector(pc[i].x,pc[i].y);
		}
		return sts;
    }
}
