package com.itu.capstone.neighborhood.matcher.entity;

import javax.xml.bind.annotation.XmlElement;

public class TruliaStats {
	private Location location;
	private ListingStats listingStats;
	
	
	@XmlElement(name = "location")
	public Location getLocation() {
		return location;
	}
	public void setLocation(Location location) {
		this.location = location;
	}
	
	@XmlElement(name = "listingStats")
	public ListingStats getListingStats() {
		return listingStats;
	}
	public void setListingStats(ListingStats listingStats) {
		this.listingStats = listingStats;
	}


}
