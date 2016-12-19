package com.itu.capstone.neighborhood.matcher.entity;

public class ListingStat {
	private String weekEndingDate;
	private ListingPrice listingPrice;
	public String getWeekEndingDate() {
		return weekEndingDate;
	}
	public void setWeekEndingDate(String weekEndingDate) {
		this.weekEndingDate = weekEndingDate;
	}
	public ListingPrice getListingPrice() {
		return listingPrice;
	}
	public void setListingPrice(ListingPrice listingPrice) {
		this.listingPrice = listingPrice;
	}
}
