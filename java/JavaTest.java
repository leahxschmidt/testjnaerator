import java.net.InetAddress;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.nio.IntBuffer;

import org.getlantern.test.*;

public class JavaTest {

    public static void main(String[] args) {

        TestLibrary test = TestLibrary.INSTANCE;
	ByteBuffer addressBytes = ByteBuffer.allocateDirect(4);
	IntBuffer address = addressBytes.asIntBuffer();
	System.out.println("before");
	int result = test.test(address);
	System.out.println("result = " + result);
	byte[] bytes = new byte[4];
	addressBytes.get(bytes);
	try {
	    InetAddress inetAddress = InetAddress.getByAddress(bytes);
	    System.out.println("Default gateway is " + inetAddress);
	} catch (UnknownHostException e) {
	    throw new RuntimeException(e);
	}
    }
}
