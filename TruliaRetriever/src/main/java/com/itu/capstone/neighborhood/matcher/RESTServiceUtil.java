package com.itu.capstone.neighborhood.matcher;

import java.io.IOException;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**REST Util class to faciliate API calls
 * @author aparna
 *
 */
public final class RESTServiceUtil {
	
	
	private RESTServiceUtil() {}
	
	private static ResponseEntity<String> execute(HttpUriRequest request) {
		CloseableHttpClient httpClient = HttpClients.custom().build();
		HttpResponse httpResponse = null;
		String retSrc = null;
		try {
	      // Execute HTTP request
	      httpResponse = httpClient.execute(request);
	      if(httpResponse.getEntity()!=null){
	    	  retSrc = EntityUtils.toString(httpResponse.getEntity());  
	      }
	      
	    } catch (IOException e) {
			e.printStackTrace();
		} finally {
	      // When HttpClient instance is no longer needed,
	      // shut down the connection manager to ensure
	      // immediate deallocation of all system resources
	    	try {
	    		httpClient.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	    if(httpResponse != null) {
	    	return new ResponseEntity<String>(retSrc, 
	    										HttpStatus.valueOf(httpResponse.getStatusLine().getStatusCode()));
	    }

		return new ResponseEntity<String>(retSrc, HttpStatus.SERVICE_UNAVAILABLE);
	}
	
	public static ResponseEntity<String> get(String urlStr) {
		HttpGet httpGetRequest = new HttpGet(urlStr);
		return execute(httpGetRequest);
	}
}
