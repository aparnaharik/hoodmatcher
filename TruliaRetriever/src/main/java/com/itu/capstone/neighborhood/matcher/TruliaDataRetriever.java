package com.itu.capstone.neighborhood.matcher;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.itu.capstone.neighborhood.matcher.entity.ListingStat;
import com.itu.capstone.neighborhood.matcher.entity.ListingStats;
import com.itu.capstone.neighborhood.matcher.entity.LocationInfo;
import com.itu.capstone.neighborhood.matcher.entity.Neighborhood;
import com.itu.capstone.neighborhood.matcher.entity.Subcategory;
import com.itu.capstone.neighborhood.matcher.entity.TruliaStats;
import com.itu.capstone.neighborhood.matcher.entity.TruliaWebServices;

/**Neighborhood Data Retriever from Trulia Public API
 * @author aparna
 *
 */
public class TruliaDataRetriever {

	private static final String COMMA = ",";

	public static void main(String[] args) throws JAXBException, IOException, InterruptedException {
		getNeighborhoodStats("San Francisco");
	}

	/**Get Neighborhood Id's for a given city
	 * @param city
	 * @return
	 * @throws IOException
	 * @throws UnsupportedEncodingException
	 * @throws JAXBException
	 * @throws InterruptedException
	 */
	private static List<Integer> getNeighborhoodList(String city)
			throws IOException, UnsupportedEncodingException, JAXBException, InterruptedException {
		List<Integer> neighborhoodIds = new ArrayList<Integer>();
		//Make API call
		ResponseEntity<String> truliaWebSvcResponse = RESTServiceUtil
				.get("http://api.trulia.com/webservices.php?library=LocationInfo&function=getNeighborhoodsInCity&state=CA&apikey=<apikey>&city="
						+ city);

		//Parse response
		JAXBContext jaxbContext = JAXBContext.newInstance(TruliaWebServices.class);
		Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
		TruliaWebServices response = (TruliaWebServices) jaxbUnmarshaller
				.unmarshal(new StringReader(truliaWebSvcResponse.getBody()));

		LocationInfo locationInfo = response.getResponse().getLocationInfo();
		List<Neighborhood> neighborhoodList = locationInfo.getNeighborhood();

		if (neighborhoodList != null) {
			for (Neighborhood neighborhood : neighborhoodList) {
				//Add neighborhood Id's to a List
				neighborhoodIds.add(neighborhood.getId());
			}
		}
		return neighborhoodIds;
	}

	/**Get Neighborhood stats for all neighborhoods in a given city
	 * @param city
	 * @throws IOException
	 * @throws UnsupportedEncodingException
	 * @throws JAXBException
	 * @throws InterruptedException
	 */
	private static void getNeighborhoodStats(String city)
			throws IOException, UnsupportedEncodingException, JAXBException, InterruptedException {
		List<Integer> neighborhoodIds = getNeighborhoodList(city);
		BufferedWriter writer = Files.newBufferedWriter(Paths.get("SFNeighborhoodStats.csv"));
		JAXBContext jaxbContext = JAXBContext.newInstance(TruliaWebServices.class);
		Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

		for (Integer id : neighborhoodIds) {
			//Make API call to Trulia
			ResponseEntity<String> truliaWebSvcResponse = RESTServiceUtil
					.get("http://api.trulia.com/webservices.php?library=TruliaStats&function=getNeighborhoodStats&startDate=2016-06-01&endDate=2016-08-30&apikey=pchajy9uzsnusvhk8p7sptze&statType=listings&neighborhoodId="
							+ id);
			if (truliaWebSvcResponse.getStatusCode() == HttpStatus.OK) {
				//Parse Response
				TruliaWebServices response = (TruliaWebServices) jaxbUnmarshaller
						.unmarshal(new StringReader(truliaWebSvcResponse.getBody()));

				TruliaStats truliaStats = response.getResponse().getTruliaStats();
				ListingStats listingStats = truliaStats.getListingStats();
				if (listingStats.getListingStat() != null) {
					for (ListingStat listingStat : listingStats.getListingStat()) {
						if (listingStat.getListingPrice().getSubcategory() != null) {
							for (Subcategory subcategory : listingStat.getListingPrice().getSubcategory()) {
								//Write required response info to a csv file
								writer.write(truliaStats.getLocation().getNeighborhoodId() + COMMA
										+ truliaStats.getLocation().getNeighborhoodName() + COMMA
										+ truliaStats.getLocation().getCity() + COMMA
										+ truliaStats.getLocation().getNeighborhoodGuideURL() + COMMA
										+ truliaStats.getLocation().getHeatMapURL() + COMMA
										+ listingStat.getWeekEndingDate() + COMMA + subcategory.getType() + COMMA
										+ subcategory.getNumberOfProperties() + COMMA
										+ subcategory.getMedianListingPrice() + COMMA
										+ subcategory.getAverageListingPrice() + "\n");
							}
						}
					}
				}
				//Add sleep time to avoid exceeding Trulia API throttling (max 2 calls per second).
				Thread.sleep(1000);
			}
		}
		writer.close();
	}
}
