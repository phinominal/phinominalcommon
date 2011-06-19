package com.re.serialout;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import android.util.Log;


// The idea here is to execute everything thru temporary shell scripts. Why: (1) no more runtime idiosyncrasies once this works, (2) you can have a delayed command, (3) if root access is wanted, it'll be asked only once.
public class ExecByBatch {

	public static boolean hasroot=false;
	public static String scriptfilename="";
	public static String cmdfilename="";
	public static String dir;
	public static File scriptfile=null;
	public static File cmdfile = null;
	public static int Delay = 2;
	public static Process loop = null;
	public static final void GenerateExecutionFile(String localdir)
	{
		KillLoop();
		dir = localdir;
		scriptfilename = localdir + "/loop.sh";
		cmdfilename = localdir + "/cmd.txt";
		scriptfile = new File(scriptfilename);
		cmdfile = new File(cmdfilename);
		FileWriter writer;
		try
		{
			writer = new FileWriter(scriptfile);
			writer.write(
					"#!/system/bin/sh\n" + 
					"command=done\n" +
					"while [ \"$command\" != \"die\" ]\n" +
					"do\n" +			
					"sleep "+Delay+"\n" + 
					"read command < " + cmdfilename + "\n" +
					"if [ \"$command\" != \"done\" -a  \"$command\" != \"die\" ]\n"+
					"then\n" +
					"$command\n" +
					"echo \"done\" > " + cmdfilename+ "\n" +
					"fi\n" + 
					"done\n"
			);
			writer.close();
			writer=null;

			writer = new FileWriter(cmdfile);
			writer.write("done");
			writer.close();
			writer=null;
		}
		catch(IOException e)
		{
			Log.e("ExecByBatch", "Cannot write command file");
		}
	}

	public static final int RunCommand(String cmd) // 0 fail, 1 running, 2 running as root
	{

		String cmdname = dir + "/oneshot.sh";
		FileWriter writer;
		try
		{
			writer = new FileWriter(cmdname);
			writer.write("#!/system/bin/sh\n" + cmd+"\n");
			writer.close();
			writer=null;
		}
		catch(Exception e)
		{
			Log.e("ExecByBatch", "Cannot generate file:"+e.getMessage());
			return 0;
		}
		Runtime r = Runtime.getRuntime();
		try
		{
			r.exec(new String[]{"sh", "-c", "chmod 777 " + cmdname});
			r.exec(new String[]{"su", "-c", cmdname});
		}
		catch(Exception e)
		{
			try {
				r.exec(new String[]{"sh", "-c", cmdname}); 
			} catch (IOException e1) {
				Log.e("ExecByBatch", "Not running:"+e1.getMessage());
				return 0;
			}
			Log.i("ExecByBatch", "Running (no root) at: " + cmdname);
			return 1;
		}
		Log.i("ExecByBatch", "Running (as root) at: " + cmdname);
		return 2;
	}

// we don't necessarily know how much the delay is here..	
	public static final int RunCommandDelayed(String cmd) // 0 fail, 1 running, 2 running as root
	{
		if (scriptfile==null)
			return 0;
		if (loop==null)
			RunLoop();

		String cmdname = dir + "/oneshotdelay.sh";
		FileWriter writer;
		try
		{
			writer = new FileWriter(cmdname);
			writer.write("#!/system/bin/sh\n" + cmd+"\n");
			writer.close();
			Runtime r = Runtime.getRuntime();
			r.exec(new String[]{"sh", "-c", "chmod 777 " + cmdname});

			// now write the script's name into the loop
			writer = new FileWriter(cmdfilename);
			writer.write(cmdname);
			writer.close();
			writer=null;
		}
		catch(Exception e)
		{
			Log.e("ExecByBatch", "Cannot generate file:"+e.getMessage());
			return 0;
		}
		if (hasroot)
			return 2;
		return 1;
	}

	public static final int RunLoop() // 0 fail, 1 running, 2 running as root
	{
		KillLoop();
		Runtime r = Runtime.getRuntime();
		try
		{
			r.exec(new String[]{"sh", "-c", "chmod 777 " + scriptfilename});
			loop=r.exec(new String[]{"su", "-c", scriptfilename});
			hasroot=true;
		}
		catch(Exception e)
		{
			if (loop != null)
				loop.destroy();
			loop=null;
			try {
				loop=r.exec(new String[]{"sh", "-c", scriptfilename});
			} catch (IOException e1) {
				loop=null;
				Log.e("ExecByBatch", "Not running:"+e1.getMessage());
				return 0;
			}
			hasroot=true;
			Log.i("ExecByBatch", "Running (no root) at: " + scriptfilename);
			return 1;
		}
		Log.i("ExecByBatch", "Running (as root) at: " + scriptfilename);
		return 2;
	}
	
	public static final void KillLoop()
	{
		FileWriter writer;
		// now write the script's name into the loop

		if (loop!=null)
			loop.destroy();
		loop=null;
		try {
			writer = new FileWriter(cmdfilename);
			writer.write("die");
			writer.close();
			writer=null;
		} catch (IOException e) {}
	}
}
