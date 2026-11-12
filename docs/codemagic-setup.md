# إعداد Codemagic لإصدار تطبيق بنود

دليل مختصر لما يجب أن تفعله في واجهة Codemagic قبل أول إصدار عبر الوسم `v*`.

## 1) ربط المستودع

1. أنشئ تطبيقًا جديدًا في [Codemagic](https://codemagic.io/).
2. اربط مستودع **Bnood** (Flutter).
3. تأكد أن الفرع الذي تحتويه الوسوم عليه يتضمّن ملف `codemagic.yaml` في الجذر (مثلًا `migration/remote` ثم الدمج لاحقًا إلى الفرع الافتراضي).

## 2) تكامل App Store Connect (iOS)

1. من Apple: [App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api) — أنشئ مفتاح API بصلاحية **App Manager** أو ما يكفي للتوقيع والنشر.
2. في Codemagic: **Team settings → Integrations → App Store Connect** (أو على مستوى التطبيق).
3. أضف التكامل باسم **`bnood_app_store_connect`** (يجب أن يطابق الاسم في `codemagic.yaml`).
4. في App Store Connect تأكد أن التطبيق موجود بمعرّف الحزمة **`com.bnood.app`**.

## 3) توقيع Android (Keystore)

1. إن لم يكن لديك keystore للإنتاج، أنشئه محليًا واحتفظ بنسخة احتياطية آمنة (لا ترفعه إلى Git).
2. في Codemagic: **Code signing identities → Android → Upload keystore**.
3. سجّل المرجع باسم **`bnood_android_release`** (كما في `codemagic.yaml`).
4. للبناء المحلي اختياريًا: أنشئ `android/key.properties` (مُدرج في `.gitignore`) بالشكل:

```properties
storePassword=***
keyPassword=***
keyAlias=***
storeFile=/المسار/إلى/upload-keystore.jks
```

## 4) Google Play (مسار internal)

1. في Google Play Console: **Setup → API access** — اربط مشروع Google Cloud وأنشئ **Service account** بصلاحيات النشر للتطبيق.
2. حمّل ملف JSON للحساب (لا تضعه في Git).
3. في Codemagic: **Environment variables** → مجموعة باسم **`bnood_google_play`**:
   - المتغير: **`GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`**
   - القيمة: محتوى ملف JSON بالكامل
   - فعّل **Secret**.
4. **أول مرة فقط:** إن لم يُرفع التطبيق `com.bnood.app` إلى Play من قبل، يجب رفع **AAB واحد يدويًا** (أو إنشاء التطبيق في Console) قبل أن يعمل النشر الآلي إلى مسار **internal**.

## 5) متغيرات الإصدار (iOS)

أنشئ مجموعة بيئة باسم **`bnood_release_config`**:

| المتغير | الوصف |
|--------|--------|
| `APP_STORE_APPLE_ID` | الرقم من App Store Connect → التطبيق → App Information → **Apple ID** (ليس bundle id) |

## 6) أسماء يجب أن تطابق الملف

| النوع في Codemagic | الاسم في المشروع |
|---------------------|------------------|
| App Store Connect integration | `bnood_app_store_connect` |
| Android keystore reference | `bnood_android_release` |
| Env group (Play) | `bnood_google_play` |
| Env group (Apple ID) | `bnood_release_config` |

## 7) كيف تُطلق إصدارًا

من جهازك (بعد دمج `codemagic.yaml` ورفع التغييرات إلى الريموت):

```bash
git tag v1.0.1
git push origin v1.0.1
```

- يُشغَّل workflowان: **iOS Release (TestFlight)** و **Android Release (Play internal)**.
- اسم الإصدار = الوسم بدون `v` (مثلًا `1.0.1`).
- رقم البناء (build) = آخر رقم في المتجر + 1 لكل منصة.
- iOS: رفع إلى **TestFlight** فقط (بدون إرسال لمراجعة App Store).
- Android: رفع إلى مسار **internal** فقط (بدون ترقية للإنتاج).

## 8) ملاحظات

- إصدار Flutter في CI: **3.41.1** (مطابق لـ `.fvmrc`).
- لا تُشغَّل الاختبارات في CI (عددها كبير); يُشغَّل `flutter analyze` فقط.
- يُشغَّل `build_runner` لأن المشروع يستخدم Drift و`flutter_gen` حتى لو كانت بعض الملفات مُولَّدة في Git.
