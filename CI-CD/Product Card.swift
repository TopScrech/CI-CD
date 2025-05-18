import SwiftUI

struct ProductCard: View {
    private let product: CIProduct
    
    init(_ product: CIProduct) {
        self.product = product
    }
    
    var body: some View {
        NavigationLink {
            ProductDetails(product)
        } label: {
            VStack(alignment: .leading) {
                Text(product.attributes.name)
                Text(product.attributes.productType)
                Text(product.attributes.createdDate)
            }
        }
    }
}

//#Preview {
//    ProductCard()
//}
