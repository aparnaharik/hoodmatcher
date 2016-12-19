package com.itu.capstone.neighborhood.matcher.entity;

public class Subcategory {
	private String type;
	private int numberOfProperties;
	private int medianListingPrice;
	private int averageListingPrice;
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public int getNumberOfProperties() {
		return numberOfProperties;
	}
	public void setNumberOfProperties(int numberOfProperties) {
		this.numberOfProperties = numberOfProperties;
	}
	public int getMedianListingPrice() {
		return medianListingPrice;
	}
	public void setMedianListingPrice(int medianListingPrice) {
		this.medianListingPrice = medianListingPrice;
	}
	public int getAverageListingPrice() {
		return averageListingPrice;
	}
	public void setAverageListingPrice(int averageListingPrice) {
		this.averageListingPrice = averageListingPrice;
	}


}
