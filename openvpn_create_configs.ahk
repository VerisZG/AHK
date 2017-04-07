#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
; KONFIG START

;adres ip lub domena - pojdzie do konfiga klienta
host = XXX.XXX.XXX.XXX 

;prefix dodawany do nazw plikow przenoszonych do podfolderow userow, np. kowalski.crt -> bbck-kowalski.crt
filename_prefix = bbck-
; KONFIG END

; ustalmy dzisiejsza date
FormatTime, dzisiaj,,yyyy-MM-dd

;plik z konfiguracja
ovpn_template=
(
client
dev tun
proto udp
remote %host% 1194
resolv-retry infinite
nobind
persist-key
persist-tun
;mute-replay-warnings
ca "C:\\Program Files\\OpenVPN\\config\\%filename_prefix%ca.crt"
cert "C:\\Program Files\\OpenVPN\\config\\###.crt"
key "C:\\Program Files\\OpenVPN\\config\\###.key"
remote-cert-tls server
comp-lzo
verb 3
;mute 20
)

ca_content=
(
-----BEGIN CERTIFICATE-----
wkej zawartosc certyfikatu ca.crt serwera tutaj
-----END CERTIFICATE-----

)

;ogarnianie nazw plikow i zakladanie folderow

ZGScan(ext)
{
	global filename_prefix
	global ovpn_template
	global ca_content
	pattern := "*." . ext
	Loop, %pattern%
	{
		nazwa = %A_LoopFileName%
		ifInString, nazwa, %filename_prefix%
			StringReplace, nazwa, nazwa, %filename_prefix%
		;ustalamy nazwe pliku wynikowego
		StringTrimRight, nazwa_short, nazwa, 4
		;prefixujemy nazwy jesli trzeba i zmieniamy nazwy plikow
		nazwa_prefixed := filename_prefix . nazwa
		ifNotInString, nazwa, %filename_prefix%
			ifNotExist, %nazwa_prefixed%
				FileMove, %nazwa%, %nazwa_prefixed%
		;nazwy mamy z prefixem
		;zakladamy folder jesli trzeba
		if nazwa_short = ca
			Continue
		if !InStr(FileExist(nazwa_short), "D")
			FileCreateDir, %nazwa_short%
		;probujemy przeniesc pliki do foldera
		folder_path := nazwa_short . "\"
		FileMove, %nazwa_prefixed%, %folder_path%
		;kopiujemy ca
		ca_path := folder_path . filename_prefix . "ca.crt"
		ifNotExist, %ca_path%
			FileAppend, %ca_content%, %ca_path%
		;tworzymy plik konfiguracyjny (zawsze nadpisujac)
		configname := folder_path . StrReplace(filename_prefix, "-") . ".ovpn"
		user_name := filename_prefix . nazwa_short
		ovpn_content := StrReplace(ovpn_template, "###", user_name)
		FileDelete, %configname%
		FileAppend, %ovpn_content%, %configname%
	}
}
	
; ------------------------------------------------------------------------------------------------------------
; PROGRAM G£ÓWNY
	
ZGScan("crt")
ZGScan("key")
