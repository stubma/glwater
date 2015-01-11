package com.luma.glwater;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.os.Bundle;

public class MainActivity extends Activity implements GLSurfaceView.Renderer {
	static {
		System.loadLibrary("game");
	}
	
	private GLSurfaceView mGLSurfaceView;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
        // Create our surface view and set it as the content of our
        // Activity
        mGLSurfaceView = new GLSurfaceView(this);
        mGLSurfaceView.setRenderer(this);
        setContentView(mGLSurfaceView);
	}
	
    @Override
    protected void onResume() {
        super.onResume();
        mGLSurfaceView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mGLSurfaceView.onPause();
    }

	@Override
	public void onDrawFrame(GL10 gl) {
		draw();
	}

	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
	}
	
	private native void draw();
}
