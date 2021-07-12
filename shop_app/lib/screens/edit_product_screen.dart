import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-products';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _loading = false;
  var _editingProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _initValue = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageUrlFocusNode.addListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editingProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValue = {
          'title': _editingProduct.title,
          'description': _editingProduct.description,
          'price': _editingProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editingProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void updateImage() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(updateImage);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
  }

  Future<void> onSave(BuildContext context) async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _loading = true;
    });

    if (_editingProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editingProduct.id, _editingProduct);

      Navigator.pop(context);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editingProduct);
      } catch (error) {
        print('object');

        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error has Occured!'),
            content: Text('Something went wrong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Okay'),
              ),
            ],
          ),
        );
      }
      setState(() {
        _loading = false;
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                onSave(context);
              })
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValue['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editingProduct = Product(
                            id: _editingProduct.id,
                            isFavourite: _editingProduct.isFavourite,
                            title: value,
                            price: _editingProduct.price,
                            description: _editingProduct.description,
                            imageUrl: _editingProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter proper number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Enter price greater than 0';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editingProduct = Product(
                            id: _editingProduct.id,
                            isFavourite: _editingProduct.isFavourite,
                            title: _editingProduct.title,
                            price: double.parse(value),
                            description: _editingProduct.description,
                            imageUrl: _editingProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Enter atleast 10 Characters';
                        }
                        return null;
                      },
                      maxLines: 3,
                      onSaved: (value) {
                        _editingProduct = Product(
                            id: _editingProduct.id,
                            isFavourite: _editingProduct.isFavourite,
                            title: _editingProduct.title,
                            price: _editingProduct.price,
                            description: value,
                            imageUrl: _editingProduct.imageUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 10, right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(hintText: 'Enter URL'),
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              onSave(context);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a image url';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Enter Proper URL';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _editingProduct = Product(
                                id: _editingProduct.id,
                                isFavourite: _editingProduct.isFavourite,
                                title: _editingProduct.title,
                                price: _editingProduct.price,
                                description: _editingProduct.description,
                                imageUrl: value,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
