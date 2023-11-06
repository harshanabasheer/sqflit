import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper{
  static Future<void>createTables(sql.Database database)async{
    await database.execute("""CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    description TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)""");
  }
  static Future<sql.Database>db()async{
    return sql.openDatabase(//open sqlite db
      'demo.db',
      version:1,
      onCreate: (sql.Database database,int version)async{//write code while a databse is created for the first time
        await createTables(database);
      },
    );
  }
  //create
  static Future<int>createItem(String title,String ? description)async{
    final db=await SQLHelper.db();
    final data ={'title':title,'description':description};//creats a Map named data with 2 key-value paire
    final id =await db.insert('items', data,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
  //read all items
static Future<List<Map<String,dynamic>>> getItems()async{
    final db=await SQLHelper.db();
    return db.query('items',orderBy: "id");
}
// read a single item by id
  static Future<List<Map<String,dynamic>>> getItem(int id)async{
    final db=await SQLHelper.db();
    return db.query('items',where: "id=?",whereArgs: [id],limit: 1);
  }
  //update items by id
static Future<int>updateItem(int id,String title,String ?description)async{
    final db=await SQLHelper.db();
    final data={
      'title':title,
      'description':description,
      'createdAt':DateTime.now().toString()
    };
    final result = await db.update('items', data,where: "id=?",whereArgs: [id]);
    return result;
}
//delete
static Future<void>deleteItem(int id)async{
    final db=await SQLHelper.db();
    try{
      await db.delete('items',where: "id=?",whereArgs: [id]);
    }catch(e){
      debugPrint("Somthing went wrong:$e");
    }
}
}