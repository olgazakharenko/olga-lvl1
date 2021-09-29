package main

import (
	"bytes"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"drehnstrom.com/go-pets/petsdb"
)

var projectID string 

func main() {
	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}
	log.Printf("GOOGLE_CLOUD_PROJECT is set to %s", projectID)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"

	}
	log.Printf("Port set to: %s", port)

	fs := http.FileServer(http.Dir("assets"))
	mux := http.NewServeMux()

	// This serves the static files in the assets folder
	mux.Handle("/assets/", http.StripPrefix("/assets/", fs))

	// The rest of the routes
	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/about", aboutHandler)


	log.Printf("Webserver listening on Port: %s", port)
	http.ListenAndServe(":"+port, mux)
}
	
func indexHandler(w http.ResponseWriter, r *http.Request) {
	var pets []petsdb.Pet
	pets, error := petsdb.GetPets()
	if error != nil {
		fmt.Print(error)
	}

	data := HomePageData{
		PageTitle: "Pets Home Page",
		Pets: pets,
	}

	var tpl = template.Must(template.ParseFiles("templates/index.html", "templates/layout.html"))

	buf := &bytes.Buffer{}
	err := tpl.Execute(buf, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		log.Println(err.Error())
		return
	}

	buf.WriteTo(w)
	log.Println("Home Page Served")
}

func aboutHandler(w http.ResponseWriter, r *http.Request) {
	data := AboutPageData{
		PageTitle: "About Go Pets",
	}

	var tpl = template.Must(template.ParseFiles("templates/about.html", "templates/layout.html"))

	buf := &bytes.Buffer{}
	err := tpl.Execute(buf, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		log.Println(err.Error())
		return
	}

	buf.WriteTo(w)
	log.Println("About Page Served")
}

func addHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		data := AddPageData{
			PageTitle: "Add Pet",
		}

		var tpl = template.Must(template.ParseFiles("templates/addPet.html", "templates/layout.html"))

		buf := &bytes.Buffer{}
		err := tpl.Execute(buf, data)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			log.Println(err.Error())
			return
		}
		buf.WriteTo(w)

		log.Println("Add Page Served")
	} else {
		// Add Pet Here
		pet := petsdb.Pet{
			Email:    r.FormValue("email"),
			Owner: r.FormValue("owner"),
			Petname:     r.FormValue("petname"),
		}
		petsdb.AddPet(pet)

		// Go back to home page
		http.Redirect(w, r, "/", http.StatusFound)
	}
}

// HomePageData for Index template
type HomePageData struct {
	PageTitle string
	Pets []petsdb.Pet
}

// AboutPageData for About template
type AboutPageData struct {
	PageTitle string
}

// AboutPageData for About template
type AddPageData struct {
	PageTitle string
}
