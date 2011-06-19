package com.phinominal.common;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import com.re.serialout.ExecByBatch;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;

/**
 * Source below is a modified a modified version of RobotEyes project by Charles L. Chen
 * 
 */

public class CameraPreviewFeed implements Callback {

	private CameraPreviewFeedInterface delegate;

	private SurfaceHolder mHolder;

	private SurfaceView mPreview;

	static public Camera mCamera;

	private boolean mTorchMode;

	private Rect r;

	private int previewHeight = 0;

	private int previewWidth = 0;

	private int previewFormat = 0;

	private byte[] mCallbackBuffer;

	private boolean busyProcessing = false;

	private ByteArrayOutputStream out;

	private int imageQuality = 20;


	public CameraPreviewFeed(SurfaceView surfaceView, CameraPreviewFeedInterface delegate) {
		super();
		mTorchMode = false;
		out = new ByteArrayOutputStream();

		this.delegate = delegate;
		mPreview = surfaceView;
		mHolder = mPreview.getHolder();
		mHolder.addCallback(this);
		mHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
	}


	public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
		mHolder.setFixedSize(w, h);
		// Start the preview
		Camera.Parameters params = mCamera.getParameters();
		previewHeight = params.getPreviewSize().height;
		previewWidth = params.getPreviewSize().width;
		previewFormat = params.getPreviewFormat();

		// Crop the edges of the picture to reduce the image size
		r = new Rect(100, 100, previewWidth - 100, previewHeight - 100);

		mCallbackBuffer = new byte[460800];

		mCamera.setParameters(params);
		mCamera.setPreviewCallbackWithBuffer(new Camera.PreviewCallback() {
			public void onPreviewFrame(byte[] imageData, Camera arg1) {
				if (!busyProcessing) {
					busyProcessing = true;
					processImage(imageData);	
					busyProcessing = false;
				}
			}


		});
		mCamera.addCallbackBuffer(mCallbackBuffer);
		mCamera.startPreview();
		Torch(mTorchMode);

	}

	public void surfaceCreated(SurfaceHolder holder) {
		mCamera = Camera.open();
		try {
			mCamera.setPreviewDisplay(holder);
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void surfaceDestroyed(SurfaceHolder arg0) {
		if (mCamera != null) {
			mCamera.stopPreview();
			mCamera.release();
			mCamera = null;	
		}
	}

	public void destroy() {
		this.surfaceDestroyed(null);
		delegate = null;
	}

	private void processImage(byte[] imageData) {
		if (this.delegate == null) {
			return;
		}

		try {
			YuvImage yuvImage = new YuvImage(imageData, previewFormat, previewWidth, previewHeight, null);
			yuvImage.compressToJpeg(r, imageQuality, out); // Tweak the quality here - 20 seems pretty decent for quality + size.
			delegate.newImageFromCameraPreviewFeed(this, out.toByteArray());

		} catch (IllegalStateException e) {
			e.printStackTrace();
		} finally {
			out.reset();
			if (mCamera != null) {
				mCamera.addCallbackBuffer(mCallbackBuffer);
			}
		}

	}


	// add more strings as we get hands on more fones
	// Torch(torchoff); toggles

	public static boolean torchoff=true;
	public static void Torch(boolean on)
	{
		if (mCamera==null)
			return;
		Camera.Parameters p = mCamera.getParameters();
		if (on)
		{
			torchoff=false;
			p.set("flash-mode","torch");
			mCamera.setParameters(p);
			ExecByBatch.RunCommand(
					"echo 63 > /sys/class/leds/flashlight/brightness\n"+
					"echo 63 > /sys/class/leds/spotlight/brightness\n"+
					"echo 63 > /sys/class/leds/torch-flash/flash_light\n"
			);
		}
		else
		{
			torchoff=true;
			p.set("flash-mode","auto");
			mCamera.setParameters(p);
			ExecByBatch.RunCommand(
					"echo 0 > /sys/class/leds/flashlight/brightness\n"+
					"echo 0 > /sys/class/leds/spotlight/brightness\n"+
					"echo 0 > /sys/class/leds/torch-flash/flash_light\n"
			);
		}

	}


	public int getImageQuality() {
		return imageQuality;
	}


	public void setImageQuality(int imageQuality) {
		this.imageQuality = imageQuality;
	}

}
