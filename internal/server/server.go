package server

import (
	"log"
	"net/http"
)

func New(port string) *http.Server {
	mux := http.NewServeMux()
	registerRoutes(mux)

	return &http.Server{
		Addr:    ":" + port,
		Handler: mux,
	}
}

func registerRoutes(mux *http.ServeMux) {
	mux.HandleFunc("/health", handleHealth())
	mux.HandleFunc("/", handleHello())
}

func handleHello() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s", r.Method, r.URL.Path)
		w.Header().Set("Content-Type", "text/plain")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Hello, World!\n"))
	}
}

func handleHealth() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	}
}
