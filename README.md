#Realtime Storage for React-Native

Realtime Cloud Storage is a fully managed NoSQL database service based on Amazon DynamoDB that provides fast and predictable performance with seamless scalability.

If you are a developer, you can use Realtime Cloud Storage to create database tables that can store and retrieve any amount of data, and serve any level of request traffic.

##Installation

* Create a new react-native project. [Check react-native getting started](http://facebook.github.io/react-native/docs/getting-started.html#content)

* On the terminal, go to PROJECT_DIR/node_modules/react-native.

* Execute

		 npm install --save react-native-realtimestorage-ios

* Drag RCTRealtimeCloudStorage.xcodeproj from the node_modules/react-native-realtimestorage-ios folder into your XCode project. Click on the project 	in XCode, goto Build Phases then Link Binary With Libraries and add 	libRCTRCTRealtimeCloudStorage.a

* Drag RCTRealtimeCloudStorage.js to your root project directory.


 You are ready to go.

## The todo list example
If you want to check a ready to run example using this SDK check the real-time synced todo list manager at [https://github.com/realtime-framework/StorageReactNativeTodo](https://github.com/realtime-framework/StorageReactNativeTodo)



##Importing RCTRealtimeCloudStorageIOS to your project

	var module = require('RCTRealtimeCloudStorageIOS');
	var RCTRealtimeCloudStorage = new module();

## Documentation

####ProvisionLoad list

* "ProvisionLoad_READ"

* "ProvisionLoad_WRITE"

* "ProvisionLoad_BALANCED"


####ProvisionType list

* "ProvisionType_LIGHT"
 
* "ProvisionType_MEDIUM"

* "ProvisionType_INTERMEDIATE"

* "ProvisionType_HEAVY"

* "ProvisionType_CUSTOM"


####StorageDataType list

* "StorageDataType_STRING"

* "StorageDataType_NUMBER"

####StorageOrder list

* "StorageOrder_NULL"

* "StorageOrder_ASC"

* "StorageOrder_DESC"

####StorageEventType list

* "StorageEvent_PUT"

* "StorageEvent_UPDATE"

* "StorageEvent_DELETE"
	
	
## RCTRealtimeCloudStorageIOS class reference

###storageRef(aApplicationKey, aPrivateKey, aAuthenticationToken)

Initialize the Storage Reference. Should be the first thing to do.

**Parameters**

* applicationKey -
The application key.

* privateKey -
The application key.

* authenticationToken -
The authentication token.

***Example***

	RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');

###storageRefCustom(aApplicationKey, aPrivateKey, aAuthenticationToken, aIsCluster, aIsSecure, aUrl)

Initialize the Storage Reference. Should be the first thing to do.

**Parameters**

* sSecure -
Defines if connection use ssl.

* url -
The url of the storage server.

* applicationKey -
The application key.

* privateKey -
The application key.

* isCluster -
Specifies if url is cluster.

* authenticationToken -
The authentication token.

***Example***

	RCTRealtimeCloudStorage.storageRefCustom('ApplicationKey', 'PrivateKey', 'AuthenticationToken', true, true, 'Url')
	

###getTables(success:Function, error:Function)

Retrieves a list of the names of all tables created by the user's subscription.

**Parameters**

* success -
The block object to call once the values are available. The function will be called with a table snapshot as argument, as many times as the number of tables existent.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	storageRef.getTables(function(success){
		console.log('success: ' + success);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###table(tableName)

Creates new table reference

**Parameters**

* name -
The table name

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');

###isAuthenticated(aAuthenticationToken, success: Function, error: Function)

Checks if a specified authentication token is authenticated.

**Parameters**

* authenticationToken -
The token to verify.

* success -
The block object to call when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	storageRef.isAuthenticated(function(success){
		console.log('success: ' + success);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###onReconnected(callback: Function)

Bind a block object to be called whenever the connection is reestablished.

**Parameters**

* callback -
The block object to call when the connection reestablish.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	storageRef.onReconnected(function(){
		console.log('onReconnected');
	});


###onReconnecting(callback: Function)

Bind a block object to be called whenever the connection is lost.

**Parameters**

* onReconnecting -
The block object to call when the connection is lost.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	storageRef.onReconnecting(function(){
		console.log('onReconnecting');
	});

###activateOfflineBuffering()

Activate offline buffering, which buffers item's modifications and applies them when connection is reestablished. The offline buffering is activated by default.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	storageRef.activateOfflineBuffering();
	
###deactivateOfflineBuffering()

Deactivate offline buffering, which buffers item's modifications and applies them when connection is reestablished. The offline buffering is activated by default.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	storageRef.deactivateOfflineBuffering();
	
	
##class tableRef

### asc()

Define if the items are retrieved in ascending order.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.asc().getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###desc()

Define if the items are retrieved in descendant order.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.desc().getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###beginsWithString(item, value)

Applies a filter to the table. Only objects with item that begins with the value will be in the scope. The item type is String.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.beginsWithString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###beginsWithNumber(item, value)

Applies a filter to the table. Only objects with item that begins with the value will be in the scope. The item type is number.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.beginsWithNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###betweenString(item, beginValue, endValue)

Applies a filter to the table. Only objects with item that are in range between beginValue and endValue will be in the scope. The item type is String.

**Parameters**
* item -
The name of property to filter.

* beginValue -
The value of property indicates the beginning of range.

* endValue -
The value of property indicates the end of range.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.betweenString('item', 'beginValue', 'endValue').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});


###betweenNumber(item, beginValue, endValue)

Applies a filter to the table. Only objects with item that are in range between beginValue and endValue will be in the scope. The item type is number.

**Parameters**
* item -
The name of property to filter.

* beginValue -
The value of property indicates the beginning of range.

* endValue -
The value of property indicates the end of range.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.betweenNumber('item', 0, 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###containsString(item, value)

Applies a filter to the table. Only objects with item that contains the filter value will be in the scope. The item type is String.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.containsString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###containsNumber(item, value)

Applies a filter to the table. Only objects with item that contains the filter value will be in the scope. The item type is number.

**Parameters**
* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.containsNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###equalsString(item, value)

Applies a filter to the table. Only objects with item that match the filter value will be in the scope. The item type is string.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.equalsString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###equalsNumber(item, value)

Applies a filter to the table. Only objects with item that match the filter value will be in the scope. The item type is number.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.equalsNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###greaterEqualString(item, value)

Applies a filter to the table. Only objects with item greater or equal to filter value will be in the scope. The item type is String.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.greaterEqualString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###greaterEqualNumber(item, value)

Applies a filter to the table. Only objects with item greater or equal to filter value will be in the scope. The item type is number.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.greaterEqualNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###greaterThanString(item, value)

Applies a filter to the table. Only objects with item greater than filter value will be in the scope. The item type is String.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.greaterThanString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});
	
###greaterThanNumber(item, value)

Applies a filter to the table. Only objects with item greater than filter value will be in the scope. The item type is number.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.greaterThanNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});
	

###lesserEqualString(item, value)

Applies a filter to the table. Only objects with item lesser or equal to filter value will be in the scope. The item type is String.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.lesserEqualString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###lesserEqualNumber(item, value)

Applies a filter to the table. Only objects with item lesser or equal to filter value will be in the scope. The item type is number.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.lesserEqualNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###lesserThanString(item, value)

Applies a filter to the table. Only objects with item lesser than filter value will be in the scope. The item type is String.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.lesserThanString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###lesserThanNumber(item, value)

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.lesserThanNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});


###notContainsString(item, value)

Applies a filter to the table. Only objects with item that does not contains the filter value will be in the scope. The item type is String.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.notContainsString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###notContainsNumber(item, value)

Applies a filter to the table. Only objects with item that does not contains the filter value will be in the scope. The item type is number.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.notContainsNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###notEqualString(item, value)

Applies a filter to the table. Only objects with item that does not match the filter value will be in the scope. The item type is String.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.notEqualString('item', 'value').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###notEqualNumber(item, value)

Applies a filter to the table. Only objects with item that does not match the filter value will be in the scope. The item type is number.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.notEqualNumber('item', 10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###notNull(item)

Applies a filter to the table. Only objects with item that is not null will be in the scope.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.notNull('item').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###Null(item)

Applies a filter to the table. Only objects with item that is null will be in the scope.

**Parameters**

* item -
The name of property to filter.

* value -
The value of property to filter.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.Null('item').getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###create(aPrimaryKey, aPrimaryKeyDataType, aProvisionType, aProvisionLoad, success: Function, error: Function)

Adds a new table with primary key to the user's application. Take into account that, even though this operation completes, the table stays in a "creating" state. While in this state, all operations done over this table will fail with a ResourceInUseException.

**Parameters**

* success -
The block object to call when the operation is completed.

* primaryKey -
The primary key

* primaryKeyDataType -
The primary key data type (StorageDataType: StorageDataType_STRING or StorageDataType_NUMBER)

* provisionLoad -
The ProvisionLoad (ProvisionLoad_READ, ProvisionLoad_WRITE or ProvisionLoad_BALANCED)

* provisionType -
The ProvisionType (ProvisionType_LIGHT, ProvisionType_MEDIUM, ProvisionType_INTERMEDIATE, ProvisionType_HEAVY or ProvisionType_CUSTOM)

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.create('PrimaryKey', 'PrimaryKeyDataType', 'ProvisionType', 'ProvisionLoad', function(success){
		console.log('table ' + ((succes == true) ? 'created' : 'not created'));
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###createCustom(aPrimaryKey, aPrimaryKeyDataType, aSecondaryKey, aSecondaryKeyDataType, aProvisionType, aProvisionLoad, success: Function, error: Function)

Adds a new table with primary and secondary keys to the user's application. Take into account that, even though this operation completes, the table stays in a "creating" state. While in this state, all operations done over this table will fail with a ResourceInUseException.

**Parameters**

* error -
The block object to call if an exception occurred.

* primaryKey -
The primary key

* provisionLoad -
The ProvisionLoad (ProvisionLoad_READ, ProvisionLoad_WRITE or ProvisionLoad_BALANCED)

* primaryKeyDataType -
The primary key data type (StorageDataType: StorageDataType_STRING or StorageDataType_NUMBER)

* success -
The block object to call when the operation is completed.

* secondaryKeyDataType -
The secondary key data type (StorageDataType: STRING or NUMBER)

* secondaryKey -
The secondary key

* provisionType -
The ProvisionType ('ProvisionType_LIGHT', 'ProvisionType_MEDIUM', 'ProvisionType_INTERMEDIATE', 'ProvisionType_HEAVY' or 'ProvisionType_CUSTOM')

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.createCustom('PrimaryKey', 'PrimaryKeyDataType', 'SecondaryKey', 'SecondaryKeyDataType', 'ProvisionType', 'ProvisionLoad', function(success){
		console.log('table ' + ((succes == true) ? 'created' : 'not created'));
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###del(success: Function, error: Function)

Deletes a table and all of its items.

**Parameters**

* result -
The block object to call when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.del(function(success){
		console.log('table ' + ((succes == true) ? 'deleted' : 'not deleted'));
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###update(ProvisionType, aProvisionLoad, success: Function, error: Function)

Updates the number of operations per second and how they're distributed between read and write operations of a given table. Take into account that, even though this operation completes, the table stays in the "updating" state.

**Parameters**

* success -
The block object to call when the operation is completed.

* provisionLoad -
The ProvisionLoad (ProvisionLoad_READ, ProvisionLoad_WRITE or ProvisionLoad_BALANCED)

* provisionType -
The ProvisionType (ProvisionType_LIGHT, ProvisionType_MEDIUM, ProvisionType_INTERMEDIATE, ProvisionType_HEAVY or ProvisionType_CUSTOM)

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.update('ProvisionType', 'ProvisionLoad', function(success){
		console.log('table ' + ((succes == true) ? 'updated' : 'not updated'));
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###item(primaryKey)

Retrieves the reference to the item matching the given key. (in case that table was created only with primary key)

**Parameters**

* primaryKey -
The primary key (If the primary key type is Number you have to convert it to String)

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('primaryKey');

###itemCustom(primaryKey, secondaryKey)

Retrieves the reference to the item matching the given pair of keys.

**Parameters**

* primaryKey -
The primary key (If the primary key type is Number you have to convert it to String)

* secondaryKey -
The secondary key (If the primary key type is Number you have to convert it to String)

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.itemCustom('primaryKey', 'secondary');

###getItems(itemSnapshot: Function, error: Function)

Get the items of this table applying the filters if defined before, if not retrieves all items.

**Parameters**

* success -
The block object called for every item retrieved. The last call have nil as a parameter.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###push(aItem, success:Function, error: Function)

Stores an item in a table.

**Parameters**

* item -
The item to be stored (must contains primary key and secondary key if such exists)

* success -
The block object to call when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.push(item, function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###limit(value)

Applies a limit to this table reference confining the number of items to get.

**Parameters**

* limit -
The limit to apply.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.limit(10).getItems(function(item){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###meta(meta, success:Function, error: Function)

Retrieves information about the table, including the current status of the table, the primary key schema and date of creation.

**Parameters**

* success -
The block object to call when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.meta(meta, function(success){
		console.log('item: ' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###name()

Return the name of the referred table.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var tableName = tableRef.name();

###on(eventType, callback: Function)

Attach a listener to run block object every time the event type occurs.

**Parameters**

* eventType -
The type of the event to listen ('StorageEventType': 'StorageEvent_PUT', 'StorageEvent_UPDATE' or 'StorageEvent_DELETE')

* callback -
The block object which is called with the snapshot of affected item as an argument.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.on('eventType', function(item){
		console.log('event trigged');
	});

###onCustom(eventType, aPrimaryKeyValue, callback: Function)

Attach a listener to run block object every time the event type occurs for items with specific primary key.

**Parameters**

* eventType -
The type of the event to listen ('StorageEventType': 'StorageEvent_PUT', 'StorageEvent_UPDATE' or 'StorageEvent_DELETE')

* callback -
The block object which is called with the snapshot of affected item as an argument.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.onCustom('eventType', 'PrimaryKeyValue', function(item){
		console.log('event trigged');
	});

###off(eventType)

Remove an event handler for a specific selector.

**Parameters**

* eventType -
The type of the event to remove ('StorageEventType': 'StorageEvent_PUT', 'StorageEvent_UPDATE' or 'StorageEvent_DELETE')

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.off('eventType');

###offCustom(eventType, aPrimaryKey)

Remove an event handler for all block objects for a specific event type for a specific primary key.

**Parameters**

* eventType -
The type of the event to remove (StorageEventType: StorageEvent_PUT, StorageEvent_UPDATE or StorageEvent_DELETE)

* primaryKey -
The primary key of objects of interested.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.offCustom('eventType', 'PrimaryKey');

###once(eventType, callback: Function)

Attach a listener to run block object only once when the event type occurs.

**Parameters**

* eventType -
The type of the event to listen (StorageEventType: StorageEvent_PUT, StorageEvent_UPDATE or StorageEvent_DELETE)

* callback -
The block object which is called with the snapshot of affected item as an argument.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.once('eventType', function(item){
		console.log('event trigged');
	});

###onceCustom(eventType, aPrimaryKey, callback: Function)

Attach a listener to run block object only once when the event type occurs for items with specific primary key.

**Parameters**

* eventType -
The type of the event to listen (StorageEventType: StorageEvent_PUT, StorageEvent_UPDATE or StorageEvent_DELETE)

* callback -
The block object which is called with the snapshot of affected item as an argument.

* primaryKey -
The primary key of objects of interested.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.onceCustom('eventType', 'PrimaryKey', function(item){
		console.log('event trigged');
	});

###enablePushNotifications()

Enables Push Notifications for the table reference

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.enablePushNotifications();

###disablePushNotifications()

Disables Push Notifications for the table reference

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	tableRef.disablePushNotifications();

##class itemRef

###del(success: Function, error: Function)

Deletes an item specified by this reference.

**Parameters**

* success -
The block object to call with the snapshot of affected item as an argument, when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.del(function(success){
		console.log('item' + ((success == true)? 'deleted' : 'not deleted');
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###get(success: Function, error: Function)

Gets an item snapshot specified by this item reference.

**Parameters**

* success -
The block object to call with the snapshot of affected item as an argument, when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.get(function(item){
		console.log('item' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###set(attributes, success: Function, error: Function)

Updates the stored item specified by this item reference.

**Parameters**

* attributes -
The new properties of item to be updated.

* success -
The block object to call with the snapshot of affected item as an argument, when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.set(attributes,function(item){
		console.log('item' + item);
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###incr(property, value, success:Function, error:Function)

Increments a given attribute of an item by default to 1. If the attribute doesn't exist, it is set to zero before the operation.

**Parameters**

* property -
The name of the item attribute.

* success -
The block object to call with the snapshot of affected item as an argument, when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.incr('property', 10, function(success){
		console.log('item' + ((success == true)? 'incremented' : 'not incremented');
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###incrCustom(property, success:Function, error:Function)

Increments a given attribute of an item. If the attribute doesn't exist, it is set to zero before the operation.

**Parameters**

* property -
The name of the item attribute.

* value -
The number to add. Defaults to 1 if invalid.

* success -
The block object to call with the snapshot of affected item as an argument, when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.incrCustom('property', function(success){
		console.log('item' + ((success == true)? 'incremented' : 'not incremented');
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###decrValue(property, value, success:Function, error:Function)

Decrements a given attribute of an item. If the attribute doesnâ€™t exist, it is set to zero before the operation.

**Parameters**

* property -
The name of the item attribute.

* value -
The number to add. Defaults to 1 if invalid.

* success -
The block object to call with the snapshot of affected item as an argument, when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.decrValue('property', 10, function(success){
		console.log('item' + ((success == true)? 'decremented' : 'not decremented');
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###decrCustom(property, success:Function, error:Function)

Decrements a given attribute of an item by default to 1. If the attribute doesnâ€™t exist, it is set to zero before the operation.

**Parameters**

* property -
The name of the item attribute.

* success -
The block object to call with the snapshot of affected item as an argument, when the operation is completed.

* error -
The block object to call if an exception occurred.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.decrCustom('property', function(success){
		console.log('item' + ((success == true)? 'decremented' : 'not decremented');
	},
	fucntion(error){
		console.log('error: ' + error);
	});

###on(eventType:String, callback: Function)

Attach a listener to run block object every time the event type occurs for this item.

**Parameters**

* eventType -
The type of the event to listen ('StorageEventType': 'StorageEvent_PUT', 'StorageEvent_UPDATE' or 'StorageEvent_DELETE')

* callback -
The block object which is called with the snapshot of affected item as an argument.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.on('eventType', function(){
		console.log('event triggred');
	});

###off(eventType:String)

Remove an event handler for all block objects for a specific event type for this item.

**Parameters**

* eventType -
The type of the event to remove ('StorageEventType': 'StorageEvent_PUT', 'StorageEvent_UPDATE' or 'StorageEvent_DELETE')

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.off('eventType');

###once(eventType:String, callback: Function)

Attach a listener to run block object only once when the event type occurs for this item.

**Parameters**

* eventType -
The type of the event to listen ('StorageEventType': 'StorageEvent_PUT', 'StorageEvent_UPDATE' or 'StorageEvent_DELETE')

* callback -
The block object which is called with the snapshot of affected item as an argument.

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.once('eventType', function(){
		console.log('event triggred');
	});

###enablePushNotifications()

Enables Push Notifications for item reference

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.enablePushNotifications();

###disablePushNotifications()

Disables Push Notifications for item reference

***Example***

	var storageRef = RCTRealtimeCloudStorage.storageRef('ApplicationKey', 'PrivateKey', 'AuthenticationToken');
	var tableRef = storageRef.table('table name');
	var itemRef = tableRef.item('PrimaryKey');
	itemRef.disablePushNotifications();