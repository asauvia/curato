import 'package:flutter_test/flutter_test.dart';
import 'package:curato_user/features/home/domain/models/product_model.dart';

void main() {
  test('parse product response', () {
    final Map<String, dynamic> productData = {
      "attributes": {
        "size": true,
        "color": true,
        "material": false
      },
      "_id": "6a0ea780ade958416840f191",
      "name": "curato",
      "title": "curato",
      "price": 110,
      "discountPrice": 100,
      "description": "curato",
      "shortDescription": "curato",
      "image": "https://ik.imagekit.io/fbmzlnyfcj/products/product_1779345274575_jJPY48ASe.png",
      "gallery": [
        "https://ik.imagekit.io/fbmzlnyfcj/products/gallery_1779345276331_w-jrQ7Q01X.png",
        "https://ik.imagekit.io/fbmzlnyfcj/products/gallery_1779345278609_LC_WQIodj.png"
      ],
      "category": "Gifting",
      "subCategory": "Personalized Photo Frame",
      "brand": "curato",
      "stock": 100,
      "lowStockThreshold": 5,
      "trackQuantity": true,
      "weight": 0.22,
      "gst": 18,
      "hsnCode": "68613876",
      "moq": 10,
      "moqDiscount": 0,
      "requiresShipping": true,
      "seoTitle": "curato",
      "seoDescription": "curato",
      "slug": "curato",
      "youtubeLink": "",
      "status": "Active",
      "visibility": "Public",
      "variations": [
        {
          "size": "S",
          "color": "RED",
          "material": "",
          "price": 150,
          "stock": 100,
          "sku": "curato-SRED",
          "_id": "6a0ea780ade958416840f192"
        },
        {
          "size": "S",
          "color": "BLUE",
          "material": "",
          "price": 200,
          "stock": 100,
          "sku": "curato-SBLUE",
          "_id": "6a0ea780ade958416840f193"
        },
        {
          "size": "M",
          "color": "RED",
          "material": "",
          "price": 150,
          "stock": 100,
          "sku": "curato-MRED",
          "_id": "6a0ea780ade958416840f194"
        },
        {
          "size": "M",
          "color": "BLUE",
          "material": "",
          "price": 200,
          "stock": 100,
          "sku": "curato-MBLUE",
          "_id": "6a0ea780ade958416840f195"
        }
      ],
      "specs": [
        {
          "key": "curato",
          "value": "curato",
          "_id": "6a0ea780ade958416840f196"
        }
      ],
      "tags": [],
      "showOnPages": [
        "Shop",
        "Home",
        "Features",
        "Deals"
      ],
      "rating": 0,
      "numReviews": 0,
      "user": {
        "_id": "6a0ea182ade958416840f0aa",
        "name": "aman vendor",
        "email": "amanvendor@gmail.com",
        "mobile": "9860789680",
        "id": "6a0ea182ade958416840f0aa"
      },
      "relatedProducts": [],
      "createdAt": "2026-05-21T06:34:40.125Z",
      "updatedAt": "2026-05-21T06:34:40.125Z",
      "__v": 0,
      "originalPrice": 100,
      "commissionPercent": 10,
      "commissionAmount": 10,
      "sellingPrice": 110
    };

    try {
      final product = ProductModel.fromMap(productData);
      print("SUCCESS!");
      print("ID: ${product.id}");
      print("Name: ${product.name}");
      print("Variations: ${product.variations.length}");
      for (var v in product.variations) {
        print("  - SKU: ${v.sku}, Size: ${v.modelName}, Color: ${v.color}, Price: ${v.price}, Stock: ${v.stock}");
      }
      print("Weight: ${product.weight}");
      print("Length: ${product.length}, Width: ${product.width}, Height: ${product.height}");
    } catch (e, stack) {
      print("ERROR parsing: $e");
      print(stack);
      fail("parsing failed: $e");
    }
  });
}
