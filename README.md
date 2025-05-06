
# PROYEK AKHIR SSF - KELOMPOK 15

Edgrant Henderson Suryajaya - 2206025016  
Fairuz Muhammad - 2206814324  

---

### i. Introduction to the problem and the solution

Integrated Circuit (IC) adalah komponen penting dalam berbagai perangkat elektronik. Memeriksa kondisi dan fungsi setiap pin IC secara manual dapat menjadi tugas yang rumit dan memakan waktu, terutama bagi teknisi dan insinyur yang bekerja dengan banyak jenis IC. Tanpa alat yang tepat, proses pengecekan ini bisa rentan terhadap kesalahan dan tidak efisien.

Untuk mengatasi masalah ini, kami merancang sebuah alat bernama “IC Checker” yang dibuat menggunakan bahasa AVR assembly. Alat ini memungkinkan pengguna untuk memilih jenis IC yang akan diperiksa melalui 2 buah tombol. Setelah jenis IC dipilih, alat ini akan secara otomatis memeriksa semua pin IC dan menampilkan hasilnya pada LCD I2C.

---

### ii. Hardware design and implementation details

**Komponen yang dibutuhkan:**
- Arduino Uno - 1 buah
- Breadboard - 1 buah
- LED - 1 buah
- LCD 16x2 with I2C
- Kabel jumper male to male
- Kabel jumper male to female
- Baterai 9V - 1 buah
- 7805 voltage regulator

Rangkaian fisik menggunakan breadboard untuk menyambungkan komponen dan Arduino Uno sebagai controller logikanya. LCD I2C 16x2 digunakan untuk menampilkan IC AND atau OR tergantung dengan IC yang diperiksa. Untuk menghubungkan I2C LCD ke Arduino, pin SDA dan SCL digunakan karena merupakan jalur komunikasi utama untuk protokol I2C.

---

### iii. Software implementation details

Perancangan dan pengembangan software berbasis pada dokumentasi flowchart yang dibuat pertama. Software dikembangkan secara modular dengan beberapa modul utama seperti deklarasi variabel, setup, delay, serial, LCD, dan checker. Kode ini mengatur PC4 (SDA) dan PC5 (SCL) sebagai input komunikasi dan menginisialisasi modul I2C untuk mengirimkan data ke LCD.

---

### iv. Test results and performance evaluation

**Pengujian Menggunakan Proteus:**
Simulasi menggunakan Proteus menunjukkan semua fungsi berjalan dengan lancar tanpa masalah. Program Arduino berhasil mengintegrasikan input dari sensor dan mengirimkan output yang tepat ke LCD dan perangkat output lainnya.

**Pengujian Rangkaian Fisik:**
Implementasi pada rangkaian fisik menunjukkan masalah dengan modul LCD, yang hanya menampilkan kotak-kotak dan tidak berhasil menampilkan huruf atau teks yang diharapkan. Namun, logika pengecekan IC berhasil dan dapat dilihat melalui LED yang menyala sesuai dengan kondisi IC yang diuji dan output yang ditampilkan pada serial monitor.

---

### v. Conclusion and future work

Pada akhir proyek ini, dapat disimpulkan bahwa alat "IC Checker" berhasil dikembangkan sebagai sistem yang efektif untuk pengecekan IC. Alat ini dirancang untuk memilih jenis IC melalui tombol dan secara otomatis memeriksa semua pin IC yang dipilih. Hasil pengecekan ditampilkan pada LCD I2C, memberikan informasi yang jelas tentang kondisi tiap pin.

Untuk proyek berikutnya, diperlukan pemeriksaan lebih lanjut pada konfigurasi LCD untuk mengatasi masalah tampilan. Selain itu, penggunaan hardware yang lebih akurat dapat meningkatkan keandalan dan kualitas alat yang dikembangkan.
