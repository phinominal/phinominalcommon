package com.re.serialout;

// NEEDS AS MUCH OPTIMIZING AS POSSIBLE

import java.util.Arrays;
import java.util.LinkedList;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.SystemClock;

public class AudioSerialOutStereo {
	// originally from http://marblemice.blogspot.com/2010/04/generate-and-play-tone-in-android.html
	// and modified by Steve Pomeroy <steve@staticfree.info>
	// and further modified by mkb to make sure it can sit in its own object


	private  static Thread audiothread = null;
	private  static AudioTrack audiotrk = null;
	private  static byte generatedSnd[] = null;

	// set that can be edited externally
	public static int new_baudRate = 9600; // assumes N,8,1 right now
	public static int new_sampleRate = 48000; // min 4000 max 48000 
	public static int new_characterdelay = 0; // in audio frames, so depends on the sample rate. Useful to work with some microcontrollers.

	// set that is actually used
	private static int baudRate;
	private static int sampleRate;
	public static  int characterdelay = 0;

	public static LinkedList<byte[]> playque = new LinkedList<byte[]>();
	public static boolean active = false;

	public static void UpdateParameters(){
		baudRate = new_baudRate; // we're not forcing standard baud rates here specifically because we want to allow odd ones
        if (new_sampleRate > 48000)
        	new_sampleRate = 48000;
        if (new_sampleRate < 4000)
        	new_sampleRate = 4000;
		sampleRate = new_sampleRate; // min 4000 max 48000 
        if (new_characterdelay < 0)
        	new_characterdelay = 0;
		characterdelay = new_characterdelay;
		minbufsize=AudioTrack.getMinBufferSize(sampleRate, AudioFormat.CHANNEL_CONFIGURATION_STEREO, AudioFormat.ENCODING_PCM_8BIT);
	}

	public static void output(String sendthis)
	{
		playque.add(SingleSerialDAC(sendthis.getBytes(), true, true));
		audiothread.interrupt();
	}

	public static void output(byte[] sendthis)
	{
		playque.add(SingleSerialDAC(sendthis, true, true));
		audiothread.interrupt();
	}

	public static void output2(byte[] sendleft, byte[] sendright)
	{
		playque.add(DoubleSerialDAC(sendleft, sendright));
		audiothread.interrupt();
	}

	public static byte[] SingleSerialDAC(byte[] sendme,boolean chan1, boolean chan2)
	{
		int bytesinframe=10+characterdelay;
		int i=0; // counter 
		int j=0; // counter 
		int k=0; // counter 
		byte l=1; // intentional jitter used to prevent the DAC from flattening the waveform prematurely
		int m=0; // counter 
		final byte logichigh = (byte) (-127+l);
		boolean[] bits = new boolean[sendme.length*bytesinframe];
		byte[] waveform = new byte[2*(sendme.length*bytesinframe*sampleRate / baudRate)]; // 8 bit, no parity, 1 stop
		Arrays.fill(waveform, (byte) 0);
		Arrays.fill(bits, false);


		for (i=0;i<sendme.length;++i)
		{
			m=i*bytesinframe;
			//bits[m]=false;
			bits[++m]=((sendme[i]&1)==0)?false:true;
			bits[++m]=((sendme[i]&2)==0)?false:true;
			bits[++m]=((sendme[i]&4)==0)?false:true;
			bits[++m]=((sendme[i]&8)==0)?false:true;
			bits[++m]=((sendme[i]&16)==0)?false:true;
			bits[++m]=((sendme[i]&32)==0)?false:true;
			bits[++m]=((sendme[i]&64)==0)?false:true;
			bits[++m]=((sendme[i]&128)==0)?false:true;
			// now we need a stop bit, BUT we want to be able to add more (character delay) to play-nice with some microcontrollers such as the Picaxe or BS1 that need it in order to do decimal conversion natively.
			for(k=0;k<bytesinframe-9;k++)
				bits[++m]=true;
		}

		for (i=0;i<bits.length;i++)
		{
			for (k=0;k<sampleRate / baudRate;k++)
			{
				if (bits[i])
				{
					if (chan1)
						waveform[j++]=  (byte) (logichigh+l); // the +l / -l is to fool the DAC into not having a flat waveform, which it might reject
					else
						j++;
					if (chan2)
						waveform[j++]=  (byte) (logichigh+l);
					else
						j++;
					l=(byte) (0-l);
				}
				else
				{
					j+=2;
				}
			}

		}
		return waveform;
	}

	public static byte[] DoubleSerialDAC(byte[] sendme1,byte[] sendme2)
	{
		int bytesinframe=10+characterdelay;
		int maxlength = sendme1.length;
		if (maxlength<sendme2.length)
			maxlength=sendme2.length;
		int i=0; // counter 
		int j=0; // counter 
		int k=0; // counter 
		byte l=1; // intentional jitter used to prevent the DAC from flattening the waveform prematurely
		int m=0; // counter 
		final byte logichigh = (byte) (-127+l);
		boolean[] bits1 = new boolean[maxlength*bytesinframe];
		boolean[] bits2 = new boolean[maxlength*bytesinframe];
		byte[] waveform = new byte[2*(maxlength*bytesinframe*sampleRate / baudRate)]; // 8 bit, no parity, 1 stop
		Arrays.fill(waveform, (byte) 0);
		Arrays.fill(bits1, false);
		Arrays.fill(bits2, false);


		for (i=0;i<sendme1.length;++i)
		{
			m=i*bytesinframe;
			//bits[m]=false;
			bits1[++m]=((sendme1[i]&1)==0)?false:true;
			bits1[++m]=((sendme1[i]&2)==0)?false:true;
			bits1[++m]=((sendme1[i]&4)==0)?false:true;
			bits1[++m]=((sendme1[i]&8)==0)?false:true;
			bits1[++m]=((sendme1[i]&16)==0)?false:true;
			bits1[++m]=((sendme1[i]&32)==0)?false:true;
			bits1[++m]=((sendme1[i]&64)==0)?false:true;
			bits1[++m]=((sendme1[i]&128)==0)?false:true;
			// now we need a stop bit, BUT we want to be able to add more (character delay) to play-nice with some microcontrollers such as the Picaxe or BS1 that need it in order to do decimal conversion natively.
			for(k=0;k<bytesinframe-9;k++)
				bits1[++m]=true;
		}

		for (i=0;i<bits1.length;i++)
		{
			for (k=0;k<sampleRate / baudRate;k++)
			{
				if (bits1[i])
				{
					j++;
					waveform[j++]=  (byte) (logichigh+l);
					l=(byte) (0-l);
				}
				else
				{
					j+=2;
				}
			}

		}

		
		for (i=0;i<sendme2.length;++i)
		{
			m=i*bytesinframe;
			//bits[m]=false;
			bits2[++m]=((sendme2[i]&1)==0)?false:true;
			bits2[++m]=((sendme2[i]&2)==0)?false:true;
			bits2[++m]=((sendme2[i]&4)==0)?false:true;
			bits2[++m]=((sendme2[i]&8)==0)?false:true;
			bits2[++m]=((sendme2[i]&16)==0)?false:true;
			bits2[++m]=((sendme2[i]&32)==0)?false:true;
			bits2[++m]=((sendme2[i]&64)==0)?false:true;
			bits2[++m]=((sendme2[i]&128)==0)?false:true;
			// now we need a stop bit, BUT we want to be able to add more (character delay) to play-nice with some microcontrollers such as the Picaxe or BS1 that need it in order to do decimal conversion natively.
			for(k=0;k<bytesinframe-9;k++)
				bits1[++m]=true;
		}

		for (i=0;i<bits2.length;i++)
		{
			for (k=0;k<sampleRate / baudRate;k++)
			{
				if (bits2[i])
				{
					waveform[j++]=  (byte) (logichigh+l);
					j++;
					l=(byte) (0-l);
				}
				else
				{
					j+=2;
				}
			}

		}
		
		return waveform;
	}

	
	public static void activate() {
		UpdateParameters();
		// Use a new tread as this can take a while
		audiothread = new Thread(new Runnable() {
			public void run() {
				playSound();
			}
		}
		);
		audiothread.start();
		while(active == false)
		{
			try {
				Thread.sleep(50);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	public static boolean isPlaying()
	{
		try{return audiotrk.getPlaybackHeadPosition() < (generatedSnd.length);}catch(Exception e){return false;}
	}

	static int minbufsize;
	static int length;

	private static void playSound(){
		active = true;
		while(active)
		{
			try {Thread.sleep(Long.MAX_VALUE);} catch (InterruptedException e) {
				while (playque.isEmpty() == false)
				{
					if (audiotrk != null)
					{
						if (generatedSnd != null)
						{
							while (audiotrk.getPlaybackHeadPosition() < (generatedSnd.length/2))
								SystemClock.sleep(50);  // let existing sample finish first: this can probably be set to a smarter number using the information above
						}
						audiotrk.release();
					}
					UpdateParameters(); // might as well do it at every iteration, it's cheap
					generatedSnd = playque.poll();
					length = generatedSnd.length;
					if (minbufsize<length)
						minbufsize=length;
					audiotrk = new AudioTrack(AudioManager.STREAM_MUSIC,
							sampleRate, AudioFormat.CHANNEL_CONFIGURATION_STEREO,
							AudioFormat.ENCODING_PCM_8BIT, minbufsize,
							AudioTrack.MODE_STATIC);

					audiotrk.setStereoVolume(1,1);
					audiotrk.write(generatedSnd, 0, length); // numsamples is half as much?
					audiotrk.play();
					generatedSnd=null;

				}
			}
		}
	}



	/*

	public static void SerialTest2(byte[] test)
	{

	    int frames=test.length;
	    int bitsperframe=10;
	    //very time consuming need to implement this as a continous stream
	    AudioTrack serial=new AudioTrack(AudioManager.STREAM_MUSIC, baudRate, AudioFormat.CHANNEL_CONFIGURATION_MONO
	            ,AudioFormat.ENCODING_PCM_8BIT,frames*bitsperframe, AudioTrack.MODE_STATIC );
	    serial.setStereoVolume(1, 1);

	    byte[] data=new byte[frames*bitsperframe];


	    byte HIGH=0;
	    byte LOW=127;

	    int j=0;
	    int derp=0;
	    for(int i=0;i<(test.length);i++)
	    {
	    j = i*bitsperframe;
	    derp=test[i]+127;

	    data[j+0]=LOW;

	    data[j+1]=((derp&1)==0)?LOW:HIGH;
	    data[j+2]=((derp&2)==0)?LOW:HIGH;
	    data[j+3]=((derp&4)==0)?LOW:HIGH;
	    data[j+4]=((derp&8)==0)?LOW:HIGH;

	    data[j+5]=((derp&16)==0)?LOW:HIGH;
	    data[j+6]=((derp&32)==0)?LOW:HIGH;
	    data[j+7]=((derp&64)==0)?LOW:HIGH;
	    data[j+8]=((derp&128)==0)?LOW:HIGH;

	    data[j+9]=HIGH;
	    }

	    serial.write(data, 0, data.length);
	    //such a hack... using a stream will help
	    serial.play();
	    try {
	        Thread.sleep(33600*test.length/baudRate);
	    } catch (InterruptedException e) {
	        // TODO Auto-generated catch block
	        e.printStackTrace();
	    }
	    serial.stop();

	}	
	 */
}
