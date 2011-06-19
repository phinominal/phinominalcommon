package com.phinominal.common;

public class A15C_Misc {

	public static final String base64code = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		+ "abcdefghijklmnopqrstuvwxyz" + "0123456789" + "+/";
	public static final int splitLinesAt = 76;
	public static String Base64Encode(String string){

		byte[] stringArray;
		try {
			stringArray = string.getBytes("UTF-8");  // use appropriate encoding string!
		} catch (Exception ignored) {
			stringArray = string.getBytes();  // use locale default rather than croak
		}
		return Base64Encode(stringArray);
	}
	public static String Base64Encode(byte[] stringArray) {
		String encoded = "";
		// determine how many padding bytes to add to the output
		int paddingCount = (3 - (stringArray.length % 3)) % 3;
		// add any necessary padding to the input
		stringArray = zeroPad(stringArray.length + paddingCount, stringArray);
		// process 3 bytes at a time, churning out 4 output bytes
		// worry about CRLF insertions later
		for (int i = 0; i < stringArray.length; i += 3) {
			int j = ((stringArray[i] & 0xff) << 16) +
			((stringArray[i + 1] & 0xff) << 8) + 
			(stringArray[i + 2] & 0xff);
			encoded = encoded + base64code.charAt((j >> 18) & 0x3f) +
			base64code.charAt((j >> 12) & 0x3f) +
			base64code.charAt((j >> 6) & 0x3f) +
			base64code.charAt(j & 0x3f);
		}
		// replace encoded padding nulls with "="
		return splitLines(encoded.substring(0, encoded.length() -
				paddingCount) + "==".substring(0, paddingCount));

	}
	public static String splitLines(String string) {

		String lines = "";
		for (int i = 0; i < string.length(); i += splitLinesAt) {

			lines += string.substring(i, Math.min(string.length(), i + splitLinesAt));
			lines += "\r\n";

		}
		return lines;

	}

	public static byte[] zeroPad(int length, byte[] bytes) {
		byte[] padded = new byte[length]; // initialized to zero by JVM
		System.arraycopy(bytes, 0, padded, 0, bytes.length);
		return padded;
	}
	
	
	
	
	
	
    static public void decodeYUV420SP(int[] rgb, byte[] yuv420sp, int width, int height) {
    	final int frameSize = width * height;
    	
    	for (int j = 0, yp = 0; j < height; j++) {
    		int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
    		for (int i = 0; i < width; i++, yp++) {
    			int y = (0xff & ((int) yuv420sp[yp])) - 16;
    			if (y < 0) y = 0;
    			if ((i & 1) == 0) {
    				v = (0xff & yuv420sp[uvp++]) - 128;
    				u = (0xff & yuv420sp[uvp++]) - 128;
    			}
    			
    			int y1192 = 1192 * y;
    			int r = (y1192 + 1634 * v);
    			int g = (y1192 - 833 * v - 400 * u);
    			int b = (y1192 + 2066 * u);
    			
    			if (r < 0) r = 0; else if (r > 262143) r = 262143;
    			if (g < 0) g = 0; else if (g > 262143) g = 262143;
    			if (b < 0) b = 0; else if (b > 262143) b = 262143;
    			
    			rgb[yp] = 0xff000000 | ((r << 6) & 0xff0000) | ((g >> 2) & 0xff00) | ((b >> 10) & 0xff);
    		}
    	}
    }
	
	
    private void toRGB565(byte[] yuvs, int width, int height, byte[] rgbs) {
        //the end of the luminance data
        final int lumEnd = width * height;
        //points to the next luminance value pair
        int lumPtr = 0;
        //points to the next chromiance value pair
        int chrPtr = lumEnd;
        //points to the next byte output pair of RGB565 value
        int outPtr = 0;
        //the end of the current luminance scanline
        int lineEnd = width;

        while (true) {

            //skip back to the start of the chromiance values when necessary
            if (lumPtr == lineEnd) {
                if (lumPtr == lumEnd) break; //we've reached the end
                //division here is a bit expensive, but's only done once per scanline
                chrPtr = lumEnd + ((lumPtr  >> 1) / width) * width;
                lineEnd += width;
            }

            //read the luminance and chromiance values
            final int Y1 = yuvs[lumPtr++] & 0xff; 
            final int Y2 = yuvs[lumPtr++] & 0xff; 
            final int Cr = (yuvs[chrPtr++] & 0xff) - 128; 
            final int Cb = (yuvs[chrPtr++] & 0xff) - 128;
            int R, G, B;

            //generate first RGB components
            B = Y1 + ((454 * Cb) >> 8);
            if(B < 0) B = 0; else if(B > 255) B = 255; 
            G = Y1 - ((88 * Cb + 183 * Cr) >> 8); 
            if(G < 0) G = 0; else if(G > 255) G = 255; 
            R = Y1 + ((359 * Cr) >> 8); 
            if(R < 0) R = 0; else if(R > 255) R = 255; 
            //NOTE: this assume little-endian encoding
            rgbs[outPtr++]  = (byte) (((G & 0x3c) << 3) | (B >> 3));
            rgbs[outPtr++]  = (byte) ((R & 0xf8) | (G >> 5));

            //generate second RGB components
            B = Y2 + ((454 * Cb) >> 8);
            if(B < 0) B = 0; else if(B > 255) B = 255; 
            G = Y2 - ((88 * Cb + 183 * Cr) >> 8); 
            if(G < 0) G = 0; else if(G > 255) G = 255; 
            R = Y2 + ((359 * Cr) >> 8); 
            if(R < 0) R = 0; else if(R > 255) R = 255; 
            //NOTE: this assume little-endian encoding
            rgbs[outPtr++]  = (byte) (((G & 0x3c) << 3) | (B >> 3));
            rgbs[outPtr++]  = (byte) ((R & 0xf8) | (G >> 5));
        }
    }	
	
	

}
