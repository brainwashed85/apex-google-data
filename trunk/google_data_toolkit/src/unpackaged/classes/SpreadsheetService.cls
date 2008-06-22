public class SpreadsheetService {
	static final String WkSheetFeed = 'http://schemas.google.com/spreadsheets/2006#worksheetsfeed';
	static final String GSX_NMSPACE = 'http://schemas.google.com/spreadsheets/2006/extended';
	static final string SPR_SHEET_LIST_URL = 'http://spreadsheets.google.com/feeds/spreadsheets/private/full';	

	GoogleService service = new GoogleService('Sheets');
	public void setAuthSubToken(string t) { service.AuthSubToken = t;	}
	 
	public string spreadsheetsfeed { get { return  SPR_SHEET_LIST_URL;	}}
			
	public GoogleData getFeed(string url) {  // pass in your own query params here 
		return service.getFeed(url); // '?return-empty=true&range=A1:C2' 
	}  
	
	public GoogleData getFeedRange(string url,string range) { 
		return service.getFeed(url + '?return-empty=true&range=' +range ); 
	} 
	public boolean canCallout { get {return service.canCallout;} }
	public GoogleData spreadsheets { get { return getFeed(	SPR_SHEET_LIST_URL ); } }
	public GoogleData getSpreadsheets() { return spreadsheets; }
	
	public GoogleData getSpreadsheetsTitle(string t) { 
		t = EncodingUtil.urlEncode(t,'UTF-8');
		return getFeed(	SPR_SHEET_LIST_URL + '?title=' +t );
	}
	public GoogleData getSpreadsheetsTitleExact(string t) { 
		t = EncodingUtil.urlEncode(t,'UTF-8');
		return getFeed(	SPR_SHEET_LIST_URL + '?title=' +t +'&title-exact=true' );
	}
	
	/* more to add 
	Spreadsheets query parameters reference
	http://code.google.com/apis/spreadsheets/reference.html#spreadsheets_Feed
	
	alt, start-index, max-results  	Supported in all feed types.
	author, updated-min, updated-max 	Supported only in spreadsheets metafeed.
	q 	Supported only in list and cell feeds. 
	
	*/
	
  	public static string getWorksheetFeedUrl(xmldom.element sheetEntry) {
 		return GoogleData.getRelLink( sheetEntry, WkSheetFeed );
 	}	
 	public GoogleData getWorksheets( xmldom.element sheetEntry ) { 
 		string workSheetFeedUrl = 	SpreadsheetService.getWorksheetFeedUrl( sheetEntry) ; 
 		return getFeed( workSheetFeedUrl );
 	}
 		
	public void updateCells ( GoogleData.Worksheet w ) {
		// use batch to update these cells
		// cells feed looks like this 
		//http://spreadsheets.google.com/feeds/cells/o15385646727495067185.2758575337567427847/od4/private/full
		string batchFeedUrl = w.getCellFeedUrl() + '/batch'; 
		service.makePostRequest( batchFeedUrl, w.getBatchFeedBody() );
		// service.responseXml has the return value if needed
	}
		
	public void updateCells ( GoogleData.Worksheet w, list<GoogleData.Cell> celList ) {
		// use batch to update these cells
		// cells feed looks like this 
		//http://spreadsheets.google.com/feeds/cells/o15385646727495067185.2758575337567427847/od4/private/full
		string batchFeedUrl = w.getCellFeedUrl() + '/batch'; 
		service.makePostRequest( batchFeedUrl, w.getBatchFeedListBody(celList) );  
	}

	public void updateCell ( GoogleData.Worksheet w, GoogleData.Cell cel ) {
		updateCells( w, new list<GoogleData.Cell>{cel} ); 
	}
 	
 	public void updateWorksheet(GoogleData.Worksheet w) { 
		string body = w.toXmlString(); 		
		service.makePutRequest( w.edit, body ); 	
	}
	
 	public void insertWorksheet(xmldom.element oneSpreadSheet, GoogleData.Worksheet w) { 
		string body = w.toXmlString(); 		
		oneSpreadSheet.dumpall();
		service.makePostRequest( GoogleData.getRelLink( oneSpreadSheet, WkSheetFeed), body ); 	
	}
	 
	public void insertRow( GoogleData listFeed, xmldom.element row) {
		GoogleData.addNameSpace( row); 
		row.attributes.put( 'xmlns:gsx',GSX_NMSPACE);
		string body = row.toXmlString();
		body = body.replace('&','&amp;'); 
		system.assert( body != null );
		service.makePostRequest( listFeed.postUrl, body);
	}
	
	public void updateRow( xmldom.element row ) { 
		GoogleData.addNameSpace( row); 
		row.attributes.put( 'xmlns:gsx', GSX_NMSPACE);
		string body = row.toXmlString();
		body = body.replace('&','&amp;'); 	
		service.makePutRequest( GoogleData.getRelLink(row,'edit'), body); 	
	}
	
	public void removeRow (  xmldom.element row ) {
		service.makeDeleteRequest( GoogleData.getRelLink(row,'edit') );	
	}
	
 	public void removeWorksheet( GoogleData.Worksheet w) { 
 		service.makeDeleteRequest( w.edit); 	
 	}
 	
 	public HttpResponse response { get { return service.response; } } 
 	public integer debug { get; set { service.debug = this.debug = value; } } 	
}