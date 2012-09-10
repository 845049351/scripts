#include <iostream>
#include <fstream>
using namespace std;

int main(){
	ifstream fin("xindeli.packages");
	string line = "";
	while (fin>>line) {
		cout<<line << "    " << "install" << endl;
	}
	return 0;
}
