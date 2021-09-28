package tasksdb

import (
	
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"cloud.google.com/go/datastore"
)

var projectID string

// Task model stored in Datastore
type Task struct {
	Added    time.Time `datastore:"added"`
	Caption  string    `datastore:"caption"`
	Email    string    `datastore:"email"`
	Likes    int       `datastore:"likes"`
	Owner    string    `datastore:"creator"`
	TaskDesc string    `datastore:"taskname"`
	Name     string    // The ID used in the datastore.
}

// GetTasks Returns all pets from datastore ordered by likes in Desc Order
func GetTasks() ([]Task, error) {

	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}

	var tasks []Task
	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	// Create a query to fetch all Task entities".
	query := datastore.NewQuery("Task").Order("-likes")
	keys, err := client.GetAll(ctx, query, &tasks)
	if err != nil {
		fmt.Println(err)
		return nil, err
	}

	// Set the id field on each Task from the corresponding key.
	for i, key := range keys {
		tasks[i].Name = key.Name
	}

	client.Close()
	return tasks, nil
}
