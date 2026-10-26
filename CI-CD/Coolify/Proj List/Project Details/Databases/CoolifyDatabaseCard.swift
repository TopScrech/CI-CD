import SwiftUI

struct CoolifyDatabaseCard: View {
    private let database: CoolifyDatabase
    
    init(_ database: CoolifyDatabase) {
        self.database = database
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(database.name)
            
            if let description = database.description, !description.isEmpty {
                Text(description)
                    .footnote()
                    .secondary()
            }
            
            if let environmentName = database.environmentName, !environmentName.isEmpty {
                Text(environmentName)
                    .footnote()
                    .secondary()
            }
        }
    }
}
