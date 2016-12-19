package com.itu.capstone.neighborhood.matcher.entity;

public class Location {
	private int neighborhoodId;
	private String neighborhoodName;
	private String city;
	private String state;
	private String searchResultsURL;
	private String neighborhoodGuideURL;
	private String cityGuideURL;
	private String heatMapURL;
	public int getNeighborhoodId() {
		return neighborhoodId;
	}
	public void setNeighborhoodId(int neighborhoodId) {
		this.neighborhoodId = neighborhoodId;
	}
	public String getNeighborhoodName() {
		return neighborhoodName;
	}
	public void setNeighborhoodName(String neighborhoodName) {
		this.neighborhoodName = neighborhoodName;
	}
	public String getCity() {
		return city;
	}
	public void setCity(String city) {
		this.city = city;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getSearchResultsURL() {
		return searchResultsURL;
	}
	public void setSearchResultsURL(String searchResultsURL) {
		this.searchResultsURL = searchResultsURL;
	}
	public String getNeighborhoodGuideURL() {
		return neighborhoodGuideURL;
	}
	public void setNeighborhoodGuideURL(String neighborhoodGuideURL) {
		this.neighborhoodGuideURL = neighborhoodGuideURL;
	}
	public String getHeatMapURL() {
		return heatMapURL;
	}
	public void setHeatMapURL(String heatMapURL) {
		this.heatMapURL = heatMapURL;
	}
	public String getCityGuideURL() {
		return cityGuideURL;
	}
	public void setCityGuideURL(String cityGuideURL) {
		this.cityGuideURL = cityGuideURL;
	}


}
