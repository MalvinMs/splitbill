# Product Requirements Document (PRD) — SplitBill

## 1. Ringkasan Produk

**Nama Produk:** SplitBill  
**Platform:** Mobile — React Native  
**Backend:** Supabase  
**Target Platform:** Android dan iOS  
**Versi PRD:** 1.0  
**Status:** MVP

SplitBill adalah aplikasi mobile untuk membantu sekelompok pengguna mencatat pengeluaran bersama, membagi biaya, mengetahui siapa berutang kepada siapa, dan mencatat pembayaran atau settlement.

Aplikasi ditujukan untuk situasi seperti perjalanan bersama teman, makan bersama, patungan kos, event kelompok, hingga pengeluaran rumah tangga.

SplitBill akan menggunakan React Native untuk aplikasi mobile dan Supabase sebagai backend utama untuk authentication, PostgreSQL database, realtime updates, file storage, dan authorization menggunakan Row Level Security.

---

# 2. Latar Belakang

Dalam aktivitas kelompok, pencatatan pengeluaran bersama sering dilakukan melalui chat, catatan manual, atau spreadsheet.

Masalah yang umum terjadi:

- Tidak jelas siapa membayar pengeluaran tertentu.
- Sulit menghitung bagian masing-masing anggota.
- Banyak transaksi kecil membuat perhitungan utang menjadi rumit.
- Anggota sulit mengetahui total utang mereka.
- Riwayat pembayaran mudah hilang.
- Perubahan transaksi tidak langsung diketahui anggota lainnya.

SplitBill menyelesaikan masalah tersebut dengan menyediakan satu tempat bersama untuk mencatat seluruh transaksi dan menghitung saldo anggota secara otomatis.

---

# 3. Tujuan Produk

Tujuan utama SplitBill adalah membuat proses patungan dan pembagian pengeluaran menjadi sederhana, transparan, dan mudah dipahami.

Produk harus memungkinkan pengguna untuk:

1. Membuat akun dan login.
2. Membuat grup pengeluaran.
3. Mengundang pengguna lain ke grup.
4. Mencatat transaksi.
5. Menentukan siapa yang membayar.
6. Membagi transaksi ke beberapa anggota.
7. Menghitung saldo setiap anggota.
8. Menampilkan siapa berutang kepada siapa.
9. Mencatat settlement.
10. Melihat riwayat transaksi.
11. Mendapatkan perubahan data secara realtime.

---

# 4. Non-Goals

Fitur berikut tidak termasuk dalam MVP:

- Integrasi langsung dengan bank.
- Transfer uang langsung melalui aplikasi.
- Integrasi payment gateway.
- OCR struk otomatis.
- Multi-currency conversion otomatis.
- AI untuk mendeteksi transaksi.
- Sistem akuntansi perusahaan.
- Marketplace atau fitur pembayaran merchant.
- Web dashboard.

Fitur-fitur tersebut dapat dipertimbangkan setelah MVP stabil.

---

# 5. Target Pengguna

## 5.1 Mahasiswa

Contoh penggunaan:

- Patungan makan.
- Patungan perjalanan.
- Pengeluaran organisasi.
- Pengeluaran kos bersama.

## 5.2 Teman atau Grup Traveling

Contoh:

- Hotel.
- Transportasi.
- Tiket.
- Makanan.
- Aktivitas wisata.

## 5.3 Teman Serumah

Contoh:

- Listrik.
- Internet.
- Air.
- Belanja kebutuhan rumah.

## 5.4 Pasangan atau Keluarga

Contoh:

- Grocery.
- Tagihan rumah.
- Pengeluaran bersama.

---

# 6. Persona Pengguna

## Persona A — Pengguna Biasa

**Nama:** Andi  
**Umur:** 22 tahun  
**Kebutuhan:** Membagi pengeluaran perjalanan bersama teman.

Pain point:

> Setelah perjalanan selesai, Andi memiliki puluhan transaksi dan kesulitan mengetahui siapa harus membayar siapa.

Tujuan:

> Andi ingin aplikasi secara otomatis menghitung utang antar anggota.

---

## Persona B — Organizer

**Nama:** Rina  
**Umur:** 25 tahun  
**Kebutuhan:** Mengelola pengeluaran grup.

Pain point:

> Rina sering harus mengingatkan teman-temannya mengenai pengeluaran dan pembayaran.

Tujuan:

> Semua anggota dapat melihat transaksi dan saldo mereka sendiri secara realtime.

---

# 7. User Journey Utama

```text
Install App
   ↓
Register / Login
   ↓
Home
   ↓
Create Group
   ↓
Invite Members
   ↓
Add Expense
   ↓
Select Payer
   ↓
Select Participants
   ↓
Choose Split Method
   ↓
Save Expense
   ↓
Balance Updated
   ↓
View Debt Summary
   ↓
Settle Up
```

---

# 8. Scope MVP

MVP akan mencakup beberapa modul utama.

## 8.1 Authentication

Pengguna dapat:

- Register.
- Login.
- Logout.
- Reset password.
- Mengubah nama.
- Mengubah foto profil.

Authentication menggunakan:

```text
Supabase Auth
```

Metode autentikasi MVP:

- Email + Password.

Future:

- Google Login.
- Apple Login.
- Magic Link.

---

# 9. Group Management

Pengguna dapat membuat grup untuk mencatat pengeluaran bersama.

Contoh:

```text
Trip Bali 2026
Anak Kos Blok C
Weekend Bandung
Office Dinner
```

## Create Group

Field:

```text
Group Name
Description
Group Image
Default Currency
```

Contoh:

```text
Name:
Trip Bali

Currency:
IDR
```

User yang membuat grup otomatis menjadi:

```text
Owner
```

---

# 10. Group Roles

MVP memiliki dua role.

## Owner

Dapat:

- Edit grup.
- Delete grup.
- Add member.
- Remove member.
- Add expense.
- Edit expense.
- Delete expense.

## Member

Dapat:

- Melihat grup.
- Add expense.
- Edit transaksi sendiri.
- Melihat balance.
- Melakukan settlement.

Role disimpan pada:

```text
group_members.role
```

---

# 11. Invite Member

User dapat menambahkan anggota melalui:

- Username.
- Email.
- Invite link.

MVP dapat memprioritaskan:

```text
Invite Code
```

Contoh:

```text
splitbill://invite/ABCD1234
```

User membuka link tersebut dan mendapatkan:

```text
Join Trip Bali?
```

Pilihan:

```text
Join Group
Cancel
```

---

# 12. Expense Management

Expense merupakan fitur utama aplikasi.

User dapat membuat transaksi baru.

## Field Expense

```text
Title
Amount
Date
Category
Paid By
Participants
Split Method
Notes
Receipt Image
```

Contoh:

```text
Title:
Dinner

Amount:
Rp450.000

Paid By:
Andi

Participants:
Andi
Rina
Budi

Split:
Equal
```

Hasil:

```text
Andi   Rp150.000
Rina   Rp150.000
Budi   Rp150.000
```

Karena Andi membayar:

```text
Rina owes Andi Rp150.000
Budi owes Andi Rp150.000
```

---

# 13. Split Methods

MVP harus mendukung minimal tiga metode pembagian.

## 13.1 Equal Split

Jumlah dibagi rata.

Contoh:

```text
Total:
Rp300.000

3 Participants

Each:
Rp100.000
```

Formula:

```text
split_amount = total / participant_count
```

---

# 13.2 Exact Amount

User menentukan nominal setiap anggota.

Contoh:

```text
Andi   Rp100.000
Budi   Rp150.000
Rina   Rp50.000
```

Validation:

```text
sum(split_amount) == expense.amount
```

---

# 13.3 Percentage

User menentukan persentase.

Contoh:

```text
Andi 50%
Budi 30%
Rina 20%
```

Validation:

```text
sum(percentages) == 100%
```

---

# 14. Balance Calculation

Setiap expense menghasilkan perubahan saldo anggota.

Contoh:

```text
Expense:
Rp300.000

Paid by:
Andi

Split:
Andi Rp100.000
Budi Rp100.000
Rina Rp100.000
```

Maka:

```text
Budi owes Andi Rp100.000
Rina owes Andi Rp100.000
```

Balance grup:

```text
Andi
+ Rp200.000

Budi
- Rp100.000

Rina
- Rp100.000
```

Convention:

```text
Positive balance
User harus menerima uang.

Negative balance
User harus membayar uang.
```

---

# 15. Debt Simplification

Aplikasi harus dapat menyederhanakan utang.

Tanpa simplification:

```text
Budi → Andi Rp100.000
Rina → Budi Rp100.000
```

Setelah simplification:

```text
Rina → Andi Rp100.000
```

Tujuan:

Mengurangi jumlah transaksi settlement yang diperlukan.

Fitur dapat dihitung saat membuka halaman balance tanpa harus menyimpan seluruh hasil simplification ke database.

---

# 16. Settlement

Settlement digunakan untuk mencatat pembayaran utang.

Contoh:

```text
Budi owes Andi
Rp100.000
```

Budi memilih:

```text
Settle Up
```

Kemudian:

```text
From:
Budi

To:
Andi

Amount:
Rp100.000

Date:
25 August 2026
```

Setelah disimpan:

```text
Budi balance:
Rp0
```

---

# 17. Group Dashboard

Ketika membuka sebuah grup, pengguna melihat:

```text
Group Name

You owe
Rp250.000

You are owed
Rp100.000
```

Kemudian:

```text
Recent Expenses
```

Contoh:

```text
Dinner
Rp450.000
Paid by Andi

Taxi Airport
Rp120.000
Paid by Budi

Hotel
Rp1.500.000
Paid by Rina
```

---

# 18. Activity Feed

Grup memiliki activity history.

Contoh:

```text
Andi added "Dinner"
Rp450.000

Budi joined the group.

Rina paid Andi
Rp150.000

Andi edited "Taxi Airport".
```

Activity feed membantu meningkatkan transparansi dalam grup.

---

# 19. Notifications

MVP dapat menggunakan in-app notification.

Contoh:

```text
Rina added a new expense.

You owe Andi Rp150.000.

Budi settled Rp100.000 with you.
```

Push notification dapat ditambahkan setelah MVP.

---

# 20. Receipt Upload

User dapat mengunggah foto receipt.

Storage:

```text
Supabase Storage
```

Bucket:

```text
expense-receipts
```

Path:

```text
{group_id}/{expense_id}/{filename}
```

Contoh:

```text
trip-bali-uuid/expense-uuid/receipt.jpg
```

---

# 21. Screen Requirements

Aplikasi memiliki screen berikut.

## Authentication

```text
Splash Screen
Onboarding Screen
Login Screen
Register Screen
Forgot Password Screen
```

## Main Application

```text
Home Screen
Groups Screen
Group Detail Screen
Create Group Screen
Edit Group Screen
Invite Member Screen
Members Screen
```

## Expenses

```text
Create Expense Screen
Expense Detail Screen
Edit Expense Screen
Split Expense Screen
```

## Balance

```text
Balance Screen
Debt Detail Screen
Settlement Screen
Settlement History Screen
```

## User

```text
Profile Screen
Edit Profile Screen
Settings Screen
```

---

# 22. Navigation

Recommended navigation:

```text
RootNavigator

├── AuthStack
│   ├── Login
│   ├── Register
│   └── ForgotPassword
│
└── MainTabs
    │
    ├── Home
    ├── Groups
    ├── Activity
    └── Profile
```

Group memiliki nested stack:

```text
GroupStack

GroupDetail
├── ExpenseDetail
├── AddExpense
├── Balance
├── Members
└── Settlement
```

Recommended library:

```text
React Navigation
```

---

# 23. Recommended React Native Stack

Mobile:

```text
React Native
TypeScript
Expo
```

Navigation:

```text
React Navigation
```

Server state:

```text
TanStack Query
```

Local state:

```text
Zustand
```

Forms:

```text
React Hook Form
```

Validation:

```text
Zod
```

Backend:

```text
Supabase
```

UI:

Pilihan:

```text
NativeWind

atau

React Native Paper
```

Recommended MVP:

```text
Expo
TypeScript
NativeWind
TanStack Query
React Hook Form
Zod
Supabase JS
```

---

# 24. Backend Architecture

```text
React Native Application
          │
          │
          ▼
Supabase Client SDK
          │
          ├── Auth
          │
          ├── PostgreSQL
          │
          ├── Realtime
          │
          ├── Storage
          │
          └── Edge Functions
```

---

# 25. Database Schema

## profiles

```sql
profiles
-------------------
id uuid PK
username text
full_name text
avatar_url text
created_at timestamptz
updated_at timestamptz
```

Relation:

```text
profiles.id → auth.users.id
```

---

## groups

```sql
groups
-------------------
id uuid PK
name text
description text
image_url text
currency text
created_by uuid FK
created_at timestamptz
updated_at timestamptz
```

---

## group_members

```sql
group_members
-------------------
id uuid PK
group_id uuid FK
user_id uuid FK
role text
joined_at timestamptz
```

Constraint:

```text
UNIQUE(group_id, user_id)
```

Role:

```text
owner
member
```

---

## expenses

```sql
expenses
-------------------
id uuid PK
group_id uuid FK
title text
amount numeric
category text
paid_by uuid FK
expense_date date
notes text
receipt_url text
created_by uuid FK
created_at timestamptz
updated_at timestamptz
```

---

## expense_splits

```sql
expense_splits
-------------------
id uuid PK
expense_id uuid FK
user_id uuid FK
amount numeric
percentage numeric nullable
created_at timestamptz
```

---

## settlements

```sql
settlements
-------------------
id uuid PK
group_id uuid FK
from_user uuid FK
to_user uuid FK
amount numeric
notes text
settled_at timestamptz
created_by uuid FK
created_at timestamptz
```

---

## group_invites

```sql
group_invites
-------------------
id uuid PK
group_id uuid FK
code text UNIQUE
created_by uuid FK
expires_at timestamptz
created_at timestamptz
```

---

## activities

```sql
activities
-------------------
id uuid PK
group_id uuid FK
user_id uuid FK
type text
entity_id uuid
metadata jsonb
created_at timestamptz
```

---

# 26. Entity Relationship

```text
auth.users
    │
    ▼
profiles
    │
    ├──────────────┐
    │              │
    ▼              ▼
groups        group_members
    │
    ▼
expenses
    │
    ▼
expense_splits

groups
    │
    ▼
settlements

groups
    │
    ▼
group_invites

groups
    │
    ▼
activities
```

---

# 27. Row Level Security

Seluruh tabel yang mengandung data pengguna harus menggunakan Supabase RLS.

RLS menjadi salah satu requirement keamanan utama.

## Groups

User hanya boleh melihat grup tempat mereka menjadi member.

Pseudo policy:

```sql
EXISTS (
    SELECT 1
    FROM group_members
    WHERE group_members.group_id = groups.id
    AND group_members.user_id = auth.uid()
)
```

---

## Group Members

User hanya dapat melihat anggota grup apabila user tersebut juga anggota grup.

---

## Expenses

User dapat membaca expense jika:

```text
auth.uid()
```

merupakan anggota:

```text
expense.group_id
```

User dapat membuat expense jika mereka merupakan anggota grup.

User hanya dapat mengedit:

```text
expense created by themselves
```

atau jika:

```text
role = owner
```

---

## Expense Splits

User hanya dapat membaca expense splits dari grup tempat mereka menjadi anggota.

---

## Settlements

User dapat membuat settlement jika:

```text
from_user = auth.uid()
```

atau sesuai aturan grup yang disepakati.

---

# 28. Realtime Requirements

Supabase Realtime digunakan untuk data berikut:

```text
expenses
expense_splits
settlements
group_members
```

Contoh:

Rina menambahkan:

```text
Dinner
Rp300.000
```

Andi sedang membuka halaman grup.

Tanpa refresh, transaksi harus muncul pada device Andi.

---

# 29. API / Data Access

Aplikasi tidak membutuhkan REST API custom untuk sebagian besar MVP.

Client akan berinteraksi melalui:

```text
Supabase JS SDK
```

Contoh:

```ts
supabase
  .from('expenses')
  .select('*')
  .eq('group_id', groupId)
```

Sensitive business logic dapat dipindahkan ke:

```text
PostgreSQL Function / RPC
```

atau:

```text
Supabase Edge Functions
```

---

# 30. Recommended Database Functions

Beberapa logic sebaiknya ditempatkan di database.

## get_group_balance

Input:

```text
group_id
```

Output:

```text
user_id
balance
```

---

## get_debt_summary

Input:

```text
group_id
```

Output:

```text
from_user
to_user
amount
```

---

## create_expense

Dapat dibuat sebagai RPC apabila aplikasi ingin menjamin:

```text
expense
+
expense_splits
```

dibuat dalam satu transaction.

---

# 31. Transaction Safety

Saat membuat expense, database harus menghindari kondisi:

```text
expense berhasil dibuat
expense_splits gagal dibuat
```

Idealnya operasi menggunakan:

```text
PostgreSQL transaction
```

melalui RPC.

Flow:

```text
create_expense()

BEGIN

INSERT expense

INSERT expense_splits

INSERT activity

COMMIT
```

Jika salah satu gagal:

```text
ROLLBACK
```

---

# 32. Currency

MVP mendukung satu currency untuk setiap grup.

Contoh:

```text
IDR
USD
SGD
MYR
```

Tidak ada currency conversion dalam MVP.

Semua expense pada sebuah grup menggunakan currency yang sama.

---

# 33. Expense Categories

Default categories:

```text
Food
Transportation
Accommodation
Shopping
Entertainment
Utilities
Groceries
Other
```

Future:

```text
Custom categories
```

---

# 34. Home Screen

Home Screen menampilkan ringkasan akun.

Contoh:

```text
Hello, Andi 👋

Overall Balance

You owe
Rp350.000

You are owed
Rp625.000
```

Kemudian:

```text
Recent Groups
```

Contoh:

```text
Trip Bali
3 members
You owe Rp150.000

Anak Kos
4 members
You are owed Rp200.000
```

---

# 35. Group Detail Screen

Contoh layout:

```text
Trip Bali

Your Balance
+ Rp250.000

[ Settle Up ]

---------------------

Expenses

Dinner
Rp450.000
Paid by Andi

Taxi
Rp150.000
Paid by Budi

Hotel
Rp2.000.000
Paid by Rina

---------------------

[ + Add Expense ]
```

---

# 36. Create Expense Flow

```text
Add Expense
     ↓
Enter Amount
     ↓
Enter Description
     ↓
Select Payer
     ↓
Select Participants
     ↓
Choose Split Type
     ↓
Review Split
     ↓
Save
```

Sebelum save:

```text
Total expense:
Rp450.000

Total split:
Rp450.000
```

Jika tidak sama:

```text
Expense cannot be saved.
```

---

# 37. Validation Requirements

## Create Expense

Amount:

```text
> 0
```

Title:

```text
required
max 100 characters
```

Participants:

```text
minimum 1
```

Split:

```text
sum(split_amount) = expense.amount
```

Percentage:

```text
sum(percentage) = 100
```

---

# 38. Error Handling

Aplikasi harus menangani beberapa kondisi.

## Network Error

Tampilkan:

```text
Unable to connect.
Check your internet connection and try again.
```

## Unauthorized

```text
You don't have permission to perform this action.
```

## Invalid Split

```text
Split total must equal the expense amount.
```

## Expired Invite

```text
This invite link has expired.
```

---

# 39. Loading State

Setiap asynchronous operation harus memiliki state:

```text
loading
success
error
```

Gunakan:

```text
Skeleton Loading
```

untuk list utama.

Gunakan spinner untuk:

```text
Submit
Save
Delete
Settlement
```

---

# 40. Empty States

Contoh ketika user belum memiliki grup:

```text
No groups yet.

Create a group and start splitting expenses with your friends.

[ Create Group ]
```

Expense kosong:

```text
No expenses yet.

Add your first expense to start tracking group spending.

[ Add Expense ]
```

---

# 41. Confirmation Dialog

Operasi destructive harus membutuhkan konfirmasi.

Contoh:

```text
Delete Expense?

This action cannot be undone.

Cancel
Delete
```

Berlaku untuk:

```text
Delete Expense
Delete Group
Remove Member
```

---

# 42. Offline Behaviour

MVP tidak wajib mendukung full offline mode.

Namun aplikasi harus:

- Menampilkan data cache terakhir.
- Menangani network error.
- Retry request ketika jaringan kembali tersedia.

TanStack Query dapat digunakan untuk caching.

Future:

```text
Offline-first architecture
```

---

# 43. Performance Requirements

Target:

```text
Initial app launch < 3 seconds
```

Pada jaringan normal.

Group expense list:

```text
< 1 second
```

untuk data yang sudah cache.

Pagination harus diterapkan jika transaksi:

```text
> 30 expenses
```

Initial pagination:

```text
20 items / page
```

---

# 44. Security Requirements

Semua akses data harus divalidasi menggunakan:

```text
Supabase Row Level Security
```

Client tidak boleh dianggap trusted.

Hal yang harus dihindari:

```text
service_role key di mobile app
```

Mobile hanya boleh menggunakan:

```text
Supabase anon key
```

Sensitive credentials hanya disimpan di backend.

---

# 45. Privacy Requirements

User hanya dapat melihat informasi grup yang mereka ikuti.

Receipt harus disimpan sebagai:

```text
private bucket
```

dan diakses menggunakan:

```text
signed URL
```

jika diperlukan.

---

# 46. Logging

Error production sebaiknya dilacak menggunakan layanan seperti:

```text
Sentry
```

Data penting:

```text
Error message
Screen
App version
Platform
Timestamp
```

Jangan menyimpan:

```text
password
access token
sensitive financial information
```

dalam log.

---

# 47. Analytics

Event analytics yang dapat dilacak:

```text
user_registered

group_created

group_joined

expense_created

expense_updated

expense_deleted

settlement_created
```

Analytics dapat menggunakan:

```text
PostHog
```

atau layanan sejenis.

Analytics bukan blocker untuk MVP.

---

# 48. Success Metrics

Setelah aplikasi dirilis, metrik utama:

## Activation

Persentase user baru yang:

```text
create / join group
+
create expense
```

Target MVP:

```text
> 50%
```

---

## Engagement

Rata-rata:

```text
expenses created / active group
```

---

## Retention

User kembali menggunakan aplikasi dalam:

```text
7 days
30 days
```

---

## Core Product Metric

Jumlah:

```text
successful settlements
```

per bulan.

---

# 49. MVP Acceptance Criteria

Produk dianggap MVP-ready jika user dapat menyelesaikan flow:

```text
Register
   ↓
Login
   ↓
Create Group
   ↓
Invite Member
   ↓
Member Join
   ↓
Create Expense
   ↓
Split Expense
   ↓
View Balance
   ↓
Create Settlement
   ↓
Balance Updated
```

tanpa menggunakan tool eksternal.

---

# 50. Project Structure

Recommended structure:

```text
src/
│
├── components/
│
├── screens/
│   ├── auth/
│   ├── home/
│   ├── groups/
│   ├── expenses/
│   ├── balance/
│   └── profile/
│
├── navigation/
│
├── features/
│   ├── auth/
│   ├── groups/
│   ├── expenses/
│   └── settlements/
│
├── hooks/
│
├── services/
│   └── supabase/
│
├── stores/
│
├── schemas/
│
├── utils/
│
├── types/
│
└── constants/
```

Supabase:

```text
supabase/
│
├── migrations/
├── functions/
└── seed.sql
```

---

# 51. Development Phases

## Phase 1 — Project Setup

Deliverables:

```text
React Native project
Expo configuration
TypeScript
Navigation
Supabase client
Environment variables
```

---

## Phase 2 — Authentication

Deliverables:

```text
Register
Login
Logout
Profile
Auth persistence
```

---

## Phase 3 — Group Management

Deliverables:

```text
Create group
Edit group
Group list
Group detail
Join group
Members
```

---

## Phase 4 — Expense Management

Deliverables:

```text
Create expense
Edit expense
Delete expense
Expense list
Expense detail
```

---

## Phase 5 — Expense Splitting

Deliverables:

```text
Equal split
Exact split
Percentage split
Split validation
```

---

## Phase 6 — Balance Engine

Deliverables:

```text
User balances
Debt calculation
Debt simplification
```

---

## Phase 7 — Settlement

Deliverables:

```text
Create settlement
Settlement history
Balance recalculation
```

---

## Phase 8 — Realtime

Deliverables:

```text
Realtime expense updates
Realtime settlement updates
Realtime member updates
```

---

## Phase 9 — Storage

Deliverables:

```text
Profile images
Group images
Expense receipts
```

---

## Phase 10 — Security

Deliverables:

```text
RLS policies
Database validation
Permission testing
```

---

# 52. Priority Matrix

## P0 — Required for MVP

- Authentication.
- Profile.
- Create group.
- Join group.
- Group members.
- Create expense.
- Equal split.
- Exact split.
- Percentage split.
- Balance calculation.
- Settlement.
- RLS.
- Basic realtime.

## P1 — Important

- Receipt upload.
- Expense categories.
- Activity feed.
- Invite links.
- Debt simplification.

## P2 — Nice to Have

- Push notification.
- Google authentication.
- Dark mode.
- Export data.
- Expense analytics.

---

# 53. Future Features

Setelah MVP, pengembangan dapat mencakup:

## Push Notifications

```text
"Rina added a Rp250.000 expense."

"You owe Budi Rp75.000."
```

## Recurring Expenses

Contoh:

```text
Rent
Internet
Netflix
Electricity
```

## Expense Charts

Visualisasi:

```text
Spending by category

Food         40%
Transport    20%
Hotel        30%
Other        10%
```

## OCR Receipt

User mengambil gambar receipt.

System mengekstrak:

```text
merchant
amount
date
items
```

## Multi-Currency

Contoh:

```text
IDR
USD
JPY
SGD
```

Dengan currency conversion.

## Export

Export group data menjadi:

```text
CSV
PDF
```

## Push Payment

Future integration:

```text
Midtrans
Xendit
Stripe
```

untuk settlement.

---

# 54. Example End-to-End Scenario

Andi membuat grup:

```text
Trip Bali
```

Anggota:

```text
Andi
Rina
Budi
```

Expense pertama:

```text
Hotel
Rp1.500.000

Paid:
Andi

Split:
Equal
```

Setiap orang:

```text
Rp500.000
```

Balance:

```text
Rina owes Andi Rp500.000
Budi owes Andi Rp500.000
```

Kemudian Budi membayar makan:

```text
Dinner
Rp300.000
```

Split:

```text
Rp100.000 / person
```

Balance berubah menjadi:

```text
Rina owes Andi Rp500.000

Budi owes Andi Rp400.000
```

Setelah perjalanan, aplikasi memberikan debt summary:

```text
Rina → Andi
Rp500.000

Budi → Andi
Rp400.000
```

Rina kemudian melakukan settlement:

```text
Rina paid Andi
Rp500.000
```

Saldo Rina menjadi:

```text
Rp0
```

---

# 55. Definition of Done

Sebuah fitur dianggap selesai apabila:

- UI telah diimplementasikan.
- Loading state tersedia.
- Error state tersedia.
- Form validation tersedia.
- Database migration tersedia jika diperlukan.
- RLS policy tersedia.
- Happy path berhasil.
- Error scenarios berhasil diuji.
- TypeScript tidak memiliki critical type error.
- Tidak terdapat sensitive key di aplikasi.
- Fitur berjalan pada Android dan iOS.

---

# 56. Kesimpulan

SplitBill MVP akan berfokus pada satu core experience:

> **Mencatat pengeluaran bersama dan secara otomatis mengetahui siapa harus membayar siapa.**

Arsitektur utama:

```text
React Native
       ↓
Supabase Auth
       ↓
PostgreSQL + RLS
       ↓
Realtime
       ↓
Storage / Edge Functions
```

Core loop aplikasi:

```text
Group
  ↓
Expense
  ↓
Split
  ↓
Balance
  ↓
Settlement
```

Dengan scope ini, SplitBill cukup kompleks untuk menunjukkan kemampuan dalam React Native, relational database, authentication, authorization, realtime application, transaction handling, dan backend security, tetapi masih realistis untuk dibangun sebagai sebuah MVP.