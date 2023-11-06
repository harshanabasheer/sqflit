import 'package:flutter/material.dart';
import 'package:sqflit/database/sqlhelper.dart';


class Home extends StatefulWidget {
  const Home({Key?key}):super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String,dynamic>> _data=[];
  bool _isLoading = true;
  void _refreshdata()async{
    final data=await SQLHelper.getItems();
    setState(() {
      _data=data;
      _isLoading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshdata();//loading the diary when the app starts
  }
  final TextEditingController _titleController=TextEditingController();
  final TextEditingController _descriptionController=TextEditingController();

  //the fn will be triggerd when the floating button is pressed
  //it will also be triggerd when you want to update an item

  void _showForm(int ? id)async{
    if(id != null){
      //==null create new item
      //!=null updating an existing itm
      final existingData=_data.firstWhere((element) => element['id']==id);//returns the first item
      _titleController.text = existingData['title'];
      _descriptionController.text=existingData['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=>Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom +120,
          ),
          child: Column(
            mainAxisSize:MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: "Description"),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(onPressed: ()async{
                if(id==null){
                  //save new journal
                  await _addItem();
                }
                if(id!=null){
                  await _updateItem(id);
                }
                //clr textfeild
                _titleController.text='';
                _descriptionController.text='';
                //close bottomsheet
                Navigator.of(context).pop();
              }, child: Text(id==null ? 'Create New':'Update')
            )
            ],
          ),
        ));
  }
  //insert new journl to the db
  Future<void>_addItem()async{
    print(_titleController.text);
    print(_descriptionController.text);

    await SQLHelper.createItem(_titleController.text,_descriptionController.text);
    _refreshdata();
  }

  //update
  Future<void>_updateItem(int id)async{
    await SQLHelper.updateItem(id,_titleController.text,_descriptionController.text);
    _refreshdata();
  }

  //delete
  Future<void>_deleteItem(int id)async{
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
    Text("Successfully Deleted")));
    _refreshdata();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQL"),
      ),
      body: _isLoading ? const Center(
        child: CircularProgressIndicator()):
      ListView.builder(
        itemCount: _data.length,
          itemBuilder: (context,index)=>Card(
            color: Colors.red,
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(_data[index]['title']),
              subtitle: Text(_data[index]['description']),
              trailing: SizedBox(width: 100,
              child: Row(children: [
                IconButton(onPressed: ()=>_showForm(_data[index]['id']),
                    icon: const Icon(Icons.edit)),
                IconButton(onPressed: ()=>_deleteItem(_data[index]['id']),
                    icon: const Icon(Icons.delete)),
              ],),),
            ),

          )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: ()=>_showForm(null),
      ),
    );
  }
}
