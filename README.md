# ExpensinatorMac 💰

A macOS expense tracking application built with SwiftUI, with AI-powered receipt scanning and Azure Functions for cloud synchronization.

## ✨ Features

### 🏠 **Expense Management**
- **Visual Dashboard**: Track total spending with beautiful charts and analytics
- **Smart Categories**: Organize expenses by category (Groceries, Rent, Utilities, Transportation, Insurance, etc.)
- **Expense Operations**: Add, edit, and delete expenses with ease
- **Bulk Actions**: Select and manage multiple expenses at once

### 📱 **AI Receipt Scanner**
- **Intelligent Scanning**: AI-powered receipt text extraction using OpenAI
- **Automatic Data Entry**: Automatically populate expense details from scanned receipts
- **Receipt Storage**: Store receipt images in Azure Blob Storage
- **Cross-Platform**: Compatible with macOS camera and document scanning

### ☁️ **Cloud Synchronization**
- **Real-time Sync**: Keep your expenses synchronized across devices
- **Azure Backend**: Robust cloud infrastructure with Azure Functions
- **MySQL Database**: Reliable data storage and retrieval
- **Offline Support**: Continue working even when offline

### 📊 **Analytics & Visualization**
- **Interactive Charts**: Visual representation of spending patterns
- **Total Tracking**: Real-time calculation of total expenses
- **Category Breakdown**: See spending distribution across categories
- **Time-based Analysis**: Track expenses over time

## 🚀 Getting Started

### Prerequisites

- **macOS 13.0+** (Ventura or later)
- **Xcode 15.0+**
- **Swift 5.9+**
- **Azure Account** (for cloud features)
- **MySQL Database** (for backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ExpensinatorMac.git
   cd ExpensinatorMac
   ```

2. **Open in Xcode**
   ```bash
   open ExpensinatorMac.xcodeproj
   ```

3. **Install Dependencies**
   The project uses Swift Package Manager. Dependencies will be automatically resolved:
   - `PythonKit` - Python integration
   - `Alamofire` - HTTP networking
   - `AIReceiptScanner` - Receipt scanning functionality

4. **Configure API Keys**
   - Copy `Config.example.plist` to `Config.plist`
   - Add your OpenAI API key to `Config.plist`
   - Or set the `OPENAI_API_KEY` environment variable
   - The app will automatically load the key from environment variables

5. **Build and Run**
   - Select your target device/simulator
   - Press `⌘ + R` to build and run

## 🗄️ Backend Setup

### Azure Functions (Cloud Functions)

1. **Navigate to cloud functions directory**
   ```bash
   cd cloud_functions
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set environment variables**
   ```bash
   # Database Configuration
   export DB_HOST="your-mysql-host"
   export DB_USER="your-mysql-user"
   export DB_PASSWORD="your-mysql-password"
   export DB_DATABASE="your-database-name"
   
   # Azure Storage
   export AZURE_STORAGE_CONNECTION_STRING="your-connection-string"
   ```

4. **Deploy to Azure**
   ```bash
   func azure functionapp publish your-function-app-name
   ```

### Database Schema

The application expects a MySQL database with the following tables:
- `expenses` - Store expense records
- `categories` - Expense categories
- `users` - User management

## 🏗️ Project Structure

```
ExpensinatorMac/
├── ExpensinatorMac/              # Main iOS/macOS app
│   ├── Main/                     # App entry point and navigation
│   ├── Models/                   # Data models (Expense, Category, User)
│   ├── Presentation/            # UI Views and ViewModels
│   │   ├── Home Page/           # Main dashboard
│   │   ├── Add Expense/         # Expense creation
│   │   └── Receipt Scanner/     # AI receipt scanning
│   ├── Services/                # Business logic and API services
│   ├── Reusable Views/          # Shared UI components
│   └── Utilities.swift          # Helper functions
├── cloud_functions/             # Azure Functions backend
│   ├── function_app.py         # API endpoints
│   ├── requirements.txt        # Python dependencies
│   └── host.json              # Azure Functions configuration
└── Tests/                      # Unit and UI tests
```

## 🔧 Key Components

### Models
- **`Expense`**: Core expense data model with amount, category, description, and receipt
- **`Category`**: Expense categorization system
- **`User`**: User management and authentication

### Services
- **`AzureService`**: Handles all API communication with Azure Functions
- **`CategoryService`**: Manages expense categories
- **`NetworkHandler`**: Core networking functionality

### Views
- **`HomePageView`**: Main dashboard with expense overview and charts
- **`AddExpenseView`**: Expense creation interface
- **`ExpenseReceiptScannerView`**: AI-powered receipt scanning
- **`ChartView`**: Visual expense analytics

## 🎯 Usage

### Adding Expenses
1. Click "**+ New Expense**" on the home page
2. Fill in expense details (amount, category, description, date)
3. Optionally attach a receipt image
4. Save to sync with the cloud

### Scanning Receipts
1. Navigate to "**Receipt Scanner**" in the sidebar
2. Take a photo or select an image of your receipt
3. Let AI extract the expense details automatically
4. Review and confirm the extracted information
5. Add to your expenses with one click

### Managing Categories
- Categories are automatically synced from the backend
- Standard categories include: Groceries, Rent, Utilities, Transportation, Insurance

### Viewing Analytics
- Total spending is displayed prominently on the dashboard
- Interactive charts show spending patterns
- Filter and analyze expenses by category and time period

## 🛠️ Development

### Architecture
- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **Azure Functions**: Serverless backend architecture

### Key Dependencies
- **PythonKit**: Integration with Python libraries
- **Alamofire**: Robust HTTP networking
- **AIReceiptScanner**: Receipt scanning capabilities

### Testing
```bash
# Run unit tests
⌘ + U

# Run UI tests
⌘ + U (select UI tests)
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request