release:
	rm -f solitairea.love
	rm -rf solitairea.love
	zip -9 -r solitaire.love .
	npx love.js solitaire.love web -c -t solitaire

server:
	live-server web/

