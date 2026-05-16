Kullanım:

piperwav "This is my English text." dosyaismi.wav
Veya repo içinden:

./script.sh "This is my English text." dosyaismi.wav
Ses değiştirmek için:

piperwav "Hello, this is a test." test.wav en_US-amy-medium
Önerdiğim İngilizce kadın sesleri:

en_US-lessac-medium varsayılan, temiz Amerikan kadın sesi
en_US-amy-medium
en_US-libritts-high
en_GB-alba-medium İngiliz aksanı denemek için
Doğruladım: Docker image build oldu, model indirildi, wav üretildi ve dosya tipi RIFF WAVE, PCM, 16 bit, mono 22050 Hz çıktı. Yeni terminal açınca piperwav direkt hazır olur; mevcut terminalde source ~/.zshrc yeterli. git status içinde daha önceden var olan .ignore-backup dosyasına dokunmadım.

