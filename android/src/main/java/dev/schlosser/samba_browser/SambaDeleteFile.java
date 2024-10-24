package dev.schlosser.samba_browser;

import android.os.Build;

import androidx.annotation.RequiresApi;

import java.io.File;
import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import jcifs.smb.NtlmPasswordAuthentication;
import jcifs.smb.SmbFile;

public class SambaDeleteFile {

    private static final int FILE_CACHE_SIZE = 8192;

    @RequiresApi(api = Build.VERSION_CODES.N)

 static void deleteFile(MethodCall call, MethodChannel.Result result)  {

                      ExecutorService executor = Executors.newSingleThreadExecutor();

        executor.execute(() -> {
            try {
                String url = call.argument("url");

                // local source file and target smb file
                 SmbFile smbFile = new SmbFile(url, new NtlmPasswordAuthentication(call.argument("domain"), call.argument("username"), call.argument("password")));

                String path = call.argument("fileName");
                File file = new File(path);

                // if (url.empty) {
                //     result.error("Can not download directory.", null, null);
                //     return;
                // }    
                    SmbFile smbFileTarget = new SmbFile(smbFile, file.getName());
                if (smbFileTarget != null && smbFileTarget.canWrite()) {
                    smbFileTarget.delete();
                    result.success("File Delete successfullu");

                }

            } catch (IOException e) {
                e.printStackTrace();
                result.error("An iO-error occurred.", e.getMessage(), null);            }
        });
   
    }
}


    
    // static void saveFile(MethodCall call, MethodChannel.Result result)  {
    //     ExecutorService executor = Executors.newSingleThreadExecutor();

    //     String url = call.argument("url");
    //     if (url.endsWith("/")) {
    //         result.error("Can not download directory.", null, null);
    //         return;
    //     }

    //     executor.execute(() -> {
    //         try {
    //             SmbFile file = new SmbFile(url, new NtlmPasswordAuthentication(call.argument("domain"), call.argument("username"), call.argument("password")));
    //             SmbFileInputStream in = new SmbFileInputStream(file);

    //             File outFile = new File(call.argument("saveFolder").toString() + call.argument("fileName").toString());
    //             FileOutputStream outStream = new FileOutputStream(outFile);

    //             byte[] fileBytes = new byte[FILE_CACHE_SIZE];
    //             int n;
    //             while(( n = in.read(fileBytes)) != -1) {
    //                 outStream.write(fileBytes, 0, n);
    //             }

    //             outStream.close();
    //             result.success(outFile.getAbsolutePath());

    //         } catch (IOException e) {
    //             result.error("An iO-error occurred.", e.getMessage(), null);
    //         }
    //     });
    // }