package com.itu.capstone.neighborhood.matcher.entity;

import javax.xml.bind.annotation.XmlElement;

public class TruliaResponse {
	private LocationInfo LocationInfo;
	private TruliaStats truliaStats;
	@XmlElement(name="LocationInfo")
	public LocationInfo getLocationInfo() {
		return LocationInfo;
	}

	public void setLocationInfo(LocationInfo locationInfo) {
		this.LocationInfo = locationInfo;
	}
	
	@XmlElement(name="TruliaStats")
	public TruliaStats getTruliaStats() {
		return truliaStats;
	}

	public void setTruliaStats(TruliaStats truliaStats) {
		this.truliaStats = truliaStats;
	}
}
