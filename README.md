# سند (Sanad) — Mobile App 📱💼

> **تطبيق لتتبّع الحسابات المالية وسجلات المعاملات بين الشركاء التجاريين (P2P Financial Ledger).**  
> يحل مشكلة إدارة الحسابات والفواتير الثنائية بين التجار بإلغاء الحساب اليدوي واستبدال مجموعات واتساب بواجهة محادثة مالية منظمة وموثقة لحظياً.

---

## 📌 عن المشروع (Overview)

**سند** ليس وسيلة تحويل أموال، بل هو **سجل مالي متزامن (Ledger)** يتيح للطرفين (المشتري والبائع):
- تسجيل الفواتير والدفعات والمرتجعات لحظة بلحظة.
- ظهور المعاملات بشكل سجل محادثة فوري ومألوف (مستوحى من بساطة واتساب).
- **شريط رصيد ثابت (Persistent Balance Bar)** يوضح دائماً من دائن ومن مدين بدقة.
- **آلية التحكم بالرصيد:** الرصيد لا يتحدّث تلقائياً إلا بعد تأكيد البائع (الطرف المستلم للمبلغ)، مما يوفر الشفافية التامة ويلغي الحاجة لأي نزاعات أو إجراءات موافقة معقدة.

---

## ✨ المميزات الرئيسية (Key Features)

- 💬 **سجل محادثة مالي (Chat-like Ledger):** كل شريك تجاري له صفحة حساب تظهر فيها جميع المعاملات في فقاعات دردشة مالية منظمة.
- 📊 **شريط رصيد دائم:** معرفة الرصيد الصافي المتبقي بنظرة واحدة أعلى الشاشة.
- 🧾 **إنشاء فواتير تفصيلية:** إضافة بنود وملاحظات، مع دعم خيار "مدفوعة فوراً كاش" بخطوة واحدة.
- 💰 **تسجيل الدفعات والمرتجعات (Payments & Returns):** توثيق كل حركة نقدية أو مرتجع بضاعة مع الإشعارات الفورية.
- ⚡ **تزامن فوري (Realtime Synchronization):** عبر Appwrite Realtime لمزامنة التغييرات مباشرة لدى كلا الطرفين دون الحاجة للتحديث اليدوي.
- 🌍 **موجّه للعمل في كافة المناطق:** ستاك تقني مستقل بالكامل (Self-Hosted) لتفادي أي حظر جغرافي.

---

## 🛠 التقنيات المستخدمة (Tech Stack)

| الجزء | التقنية | الوصف |
| :--- | :--- | :--- |
| **Frontend** | **Flutter (Dart)** | تطبيق Cross-platform يدعم Android و iOS |
| **State Management** | **Provider** | إدارة حالة التطبيق (Ledger, Auth, Partners) |
| **Backend** | **Appwrite (Self-Hosted)** | إدارة التوثيق (Auth)، قاعدة البيانات (Database)، والتزامن اللحظي (Realtime) |
| **Styling & UI** | **Custom Design System** | خط كوفي/عربي أنيق، ألوان متناسقة، ودعم Dark / Light themes |

---

## 📁 هيكلية المشروع (Project Structure)

```text
sanad/
├── lib/
│   ├── config/            # الثوابت، المسارات (Routes)، والثيمات
│   ├── models/            # نماذج البيانات (Transaction, Partner, InvoiceItem, User)
│   ├── pages/             # واجهات التطبيق
│   │   ├── auth/          # تسجيل الدخول عبر الهاتف والـ OTP وإنشاء الحساب
│   │   ├── home/          # قائمة الشركاء والحسابات الإجمالية
│   │   ├── ledger/        # سجل المعاملات بين الشريكين وإضافة معاملة جديدة
│   │   └── profile/       # إعدادات الملف الشخصي
│   ├── providers/         # طبقة إدارة الحالة (Auth, Ledger, Partners)
│   ├── services/          # خدمات Appwrite والتواصل مع السيرفر
│   ├── widgets/           # المكونات المشتركة (BalanceBar, TransactionBubble, ...)
│   ├── app.dart           # إعداد الـ MaterialApp والمسارات
│   └── main.dart          # نقطة انطلاق التطبيق
├── scripts/               # سكربتات تهيئة قاعدة بيانات Appwrite وإعداد الصلاحيات
│   ├── setup_appwrite.dart
│   └── fix_permissions.dart
└── pubspec.yaml           # مكتبات وإعدادات فلاتر
```

---

## 🚀 البدء والتشغيل (Getting Started)

### 1. المتطلبات الأساسية
- تثبيت [Flutter SDK](https://docs.flutter.dev/get-started/install) (إصدار 3.0+ أو أحدث).
- سيرفر [Appwrite](https://appwrite.io/) مجهّز (محلياً أو على VPS).

### 2. تثبيت الحزم
```bash
flutter pub get
```

### 3. إعداد خادم Appwrite
قم بضبط إعدادات الربط في `lib/config/constants.dart`:
```dart
const String appwriteEndpoint = 'https://YOUR_APPWRITE_ENDPOINT/v1';
const String appwriteProjectId = 'YOUR_PROJECT_ID';
const String appwriteDatabaseId = 'YOUR_DATABASE_ID';
```

يمكنك استخدام السكربت المخصص لإنشاء الجداول والسمات تلقائياً:
```bash
dart run scripts/setup_appwrite.dart
```

### 4. تشغيل التطبيق
```bash
flutter run
```

---

## 📄 الترخيص (License)
هذا المشروع ملك خاص لشركة **Ozmatix** ومطوريه.
