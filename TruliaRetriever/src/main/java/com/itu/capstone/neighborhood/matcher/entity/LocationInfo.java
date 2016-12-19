package com.itu.capstone.neighborhood.matcher.entity;

import java.util.List;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name="LocationInfo")
public class LocationInfo {
	private String city;
	private String state;
	private List<Neighborhood> neighborhood;
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
	public List<Neighborhood> getNeighborhood() {
		return neighborhood;
	}
	public void setNeighborhood(List<Neighborhood> neighborhood) {
		this.neighborhood = neighborhood;
	}
}
