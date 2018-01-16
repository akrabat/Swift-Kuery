/**
 Copyright IBM Corporation 2016, 2017
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

// MARK: Column

/**
 The `Column` class is used to represent a single column in an SQL table in swift.
 A combination of columns are used to construct a `Table` class which matches a specific table in an SQL database.
 The `Column` Class details the column name, the table the column belongs to, any SQL keywords which apply to the column, The number of cells and the data type of the cells.
 ### Usage Example: ###
 In this example, a ToDo table class matching a table stored in an SQL database is defined.
 The "ToDoTable" class contains the table name and three instances of the `Column` class.
 The toDo_id column is an set as autoIncrementing, containing Int32 types, primaryKey, which must be unique and not null.
 toDo_title column contains String types which are not null and toDo_completed contains Boolean types, which default to false.
 ```swift
 public class ToDoTable : Table {
    let tableName = "toDoTable"
    let toDo_id = Column("toDo_id", Int32.self, autoIncrement: true, primaryKey: true, notNull: true, unique: true)
    let toDo_title = Column("toDo_title", String.self, notNull: true)
    let toDo_completed = Column("toDo_completed", Bool.self, defaultValue: false)
 }

 ```
 */
public class Column: Field, IndexColumn {
    // MARK: Column Parameters
    /// The name of the column.
    public let name: String
    
    /// The alias of the column.
    public var alias: String?
    
    /// The table to which the column belongs.
    weak var _table: Table!
    
    /// The type of the column.
    public let type: SQLDataType.Type?
    
    /// The length of the column values according to the type.
    public let length: Int?
    
    /// An indication whether the column is the primary key of the table.
    public let isPrimaryKey: Bool
    
    /// An indication whether the column is not nullable.
    public let isNotNullable: Bool
    
    /// An indication whether the column values have to be unique.
    public let isUnique: Bool
    
    /// The default value of the column.
    public let defaultValue: Any?
    
    /// An indication whether the column autoincrements.
    public let autoIncrement: Bool
    
    /// The expression to check for values inserted into of the column.
    public let checkExpression: String?
    
    /// The collation rule for the column.
    public let collate: String?
    
    /// The table to which the column belongs.
    public var table: Table {
        return _table
    }
    
    // MARK: Column Initializer
    
    /**
     The initializer for the `Column` class. This creates an instance of `Column` using the provided parameters.
    Name must be provided, but all other fields will default to either nil or false if not given.
     ### Usage Example: ###
     In this example, an instances of the `Column` class is created to match The toDo_id column of an SQL table.
     The toDo_id column in the database is stored as an Int32 and is the tables primary key.
     To represent this a `Column` is initialised with name set to "toDo_id", type set as Int32.self (self is required to pass Int32 as the class) and primaryKey set to true.
     A feature of the primary key is that they must be unique can cannot be null so unique and notNull are set to true.
     ```swift
     let toDo_id = Column("toDo_id", Int32.self, autoIncrement: true, primaryKey: true, notNull: true, unique: true)
     ```
     */
    /// - Parameter name: The name of the column.
    /// - Parameter type: The type of the column. Defaults to nil.
    /// - Parameter length: The length of the column values according to the type. Defaults to nil.
    /// - Parameter autoIncrement: An indication whether the column autoincrements. Defaults to false.
    /// - Parameter primaryKey: An indication whether the column is the primary key of the table. Defaults to false.
    /// - Parameter notNull: An indication whether the column is not nullable. Defaults to false.
    /// - Parameter unique: An indication whether the column values have to be unique. Defaults to false.
    /// - Parameter defaultValue: The default value of the column. Defaults to nil.
    /// - Parameter check: The expression to check for values inserted into of the column. Defaults to nil.
    /// - Parameter collate: The collation rule for the column. Defaults to nil.
    public init(_ name: String, _ type: SQLDataType.Type? = nil, length: Int? = nil, autoIncrement: Bool = false, primaryKey: Bool = false, notNull: Bool = false, unique: Bool = false, defaultValue: Any? = nil, check: String? = nil, collate: String? = nil) {
        self.name = name
        self.type = type
        self.length = length
        self.autoIncrement = autoIncrement
        self.isPrimaryKey = primaryKey
        self.isNotNullable = notNull
        self.isUnique = unique
        self.defaultValue = defaultValue
        self.checkExpression = check
        self.collate = collate
    }
    
    //MARK: Column Decription Functions
    
    /**
     Function to build a String representation for referencing a `Column` instance.
     A `QueryBuilder` is used handle variances between the various database engines and produce a correct SQL description.
     This function is required to obey the `Buildable` protocol.
     ### Usage Example: ###
     In this example, we initialize `QueryBuilder` and `Column` instances.
     We then use the build function to produce a String description and print the results.
     ```swift
     let queryBuilder = QueryBuilder()
     let toDo_title = Column("toDo_title", String.self, notNull: true)
     let description = try todotable.toDo_id.build(queryBuilder: queryBuilder)
     print(description)
     //Prints toDoTable.toDo_id
     ```
     */
    /// - Parameter queryBuilder: The QueryBuilder to use.
    /// - Returns: A String representation of the column.
    /// - Throws: QueryError.syntaxError if query build fails.
    public func build(queryBuilder: QueryBuilder) throws -> String {
        let tableName = Utils.packName(table.nameInQuery, queryBuilder: queryBuilder)
        if tableName == "" {
            throw QueryError.syntaxError("Table name not set. ")
        }
        var result = tableName + "." + Utils.packName(name, queryBuilder: queryBuilder)
        if let alias = alias {
            result += " AS " + Utils.packName(alias, queryBuilder: queryBuilder)
        }
        return result
    }
    
    /**
     Function to build a String representation of the index of a `Column` instance.
     A `QueryBuilder` is used handle variances between the various database engines and produce a correct SQL description.
     ### Usage Example: ###
     In this example, we initialize `QueryBuilder` and `Column` instances.
     We then use the build function to produce a String description and print the results.
     ```swift
     let queryBuilder = QueryBuilder()
     let toDo_title = Column("toDo_title", String.self, notNull: true)
     let description = todotable.toDo_id.buildIndex(queryBuilder: queryBuilder)
     print(description)
     //Prints toDo_id
     ```
     */
    /// - Parameter queryBuilder: The QueryBuilder to use.
    /// - Returns: A String representation of the index column.
    public func buildIndex(queryBuilder: QueryBuilder) -> String {
        return Utils.packName(name, queryBuilder: queryBuilder)
    }

    /**
     Function to create a String representation of a `Column` instance for use in an SQL CREATE TABLE query.
     A `QueryBuilder` is used handle variances between the various database engines and produce a correct SQL description.
     ### Usage Example: ###
     In this example, we initialize `QueryBuilder` and `Column` instances.
     We then use the create function to produce a String description of the column and print the results.
     ```swift
     let queryBuilder = QueryBuilder()
     let toDo_title = Column("toDo_title", String.self, notNull: true)
     let description = try todotable.toDo_id.create(queryBuilder: queryBuilder)
     print(description)
     //Prints "toDo_id integer AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE"
     ```
     */
    /// - Parameter queryBuilder: The QueryBuilder to use.
    /// - Returns: A String representation of the column.
    /// - Throws: QueryError.syntaxError if column creation fails.
    public func create(queryBuilder: QueryBuilder) throws -> String {
        guard let type = type else {
            throw QueryError.syntaxError("Column type not set for column \(name). ")
        }
        
        var result = Utils.packName(name, queryBuilder: queryBuilder) + " "
        
        var typeString = type.create(queryBuilder: queryBuilder)
        if let length = length {
            typeString += "(\(length))"
        }
        if autoIncrement {
            if let createAutoIncrement = queryBuilder.createAutoIncrement {
                let autoIncrementString = createAutoIncrement(typeString)
                guard autoIncrementString != "" else {
                    throw QueryError.syntaxError("Invalid autoincrement for column \(name). ")
                }
                result += autoIncrementString
            }
            else {
                result += typeString + " AUTO_INCREMENT"
            }
        }
        else {
            result += typeString
        }
        
        if isPrimaryKey {
            result += " PRIMARY KEY"
        }
        if isNotNullable {
            result += " NOT NULL"
        }
        if isUnique {
            result += " UNIQUE"
        }
        if let defaultValue = defaultValue {
            result += " DEFAULT " + Utils.packType(defaultValue)
        }
        if let checkExpression = checkExpression {
            result += " CHECK (" + checkExpression + ")"
        }
        if let collate = collate {
            result += " COLLATE \"" + collate + "\""
        }
        return result
    }
    
    //MARK: Column Expressions

    /**
     Function to return a copy of the current `Column` instance with the given name as its alias.
     This is equivelent to the SQL AS operator.
     ### Usage Example: ###
     In this example, a `Table` instance is created which contains a `Column`.
     An alias for this `Column` instance is then created and its alias printed. 
     ```swift
     let todotable = ToDoTable()
     let aliasColumn = todotable.toDo_title.as("new name")
     print(String(describing: aliasColumn.alias))
     //Prints Optional("new name")
     ```
     */
    /// - Parameter newName: A String containing the alias for the column.
    /// - Returns: A new Column instance with the alias.
    public func `as`(_ newName: String) -> Column {
        let new = Column(name, type, length: length, primaryKey: isPrimaryKey, notNull: isNotNullable, unique: isUnique, defaultValue: defaultValue, collate: collate)
        new.alias = newName
        new._table = table
        return new
    }
    
}

