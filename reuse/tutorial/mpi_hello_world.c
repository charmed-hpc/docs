#include <mpi.h>
#include <stdio.h>
      
int main(int argc, char** argv) {
  // Initialize the MPI environment
  MPI_Init(NULL, NULL);

  // Get the number of nodes
  int size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  // Get the rank of the process
  int rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  // Get the name of the node
  char node_name[MPI_MAX_PROCESSOR_NAME];
  int name_len;
  MPI_Get_processor_name(node_name, &name_len);

  // Print hello world message
  printf("Hello world from node %s, rank %d out of %d nodes\n",
      node_name, rank, size);

  // Finalize the MPI environment.
  MPI_Finalize();
}
