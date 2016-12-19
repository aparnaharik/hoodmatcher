package com.itu.capstone.neighborhood.matcher.entity;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name="TruliaWebServices")
public class TruliaWebServices {
	private Object request;
	
	private TruliaResponse response;

	public Object getRequest() {
		return request;
	}

	public void setRequest(Object request) {
		this.request = request;
	}

	
	@XmlElement(name = "response")
	public TruliaResponse getResponse() {
		return response;
	}

	public void setResponse(TruliaResponse response) {
		this.response = response;
	}
}
