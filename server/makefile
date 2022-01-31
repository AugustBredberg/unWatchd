PYTH = python3

run:
	${PYTH} multi_server.py

test:
	@echo Om testen failar kan man behöva köra "pkill python3" för att stänga av servern
	pkill python3 || true
	${PYTH} multi_server.py &
	${PYTH} server_test.py
	pkill python3 || true
clean:
	rm -f *~
