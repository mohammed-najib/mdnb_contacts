import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MDNB Contacts'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: FutureBuilder(
              future: getContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final contactList = snapshot.data;

                  contactList?.sort((a, b) => a.displayName
                      .toLowerCase()
                      .compareTo(b.displayName.toLowerCase()));

                  if (contactList == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "You Don't Have Any Contacts",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "Or You Have Denied Permission to Access Contacts",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: contactList.length,
                    itemBuilder: (context, index) {
                      final contact = contactList[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4.0),
                          ListTile(
                            leading: FutureBuilder(
                                future:
                                    FastContacts.getContactImage(contact.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final image = snapshot.data;

                                    if (image != null) {
                                      return CircleAvatar(
                                        radius: 20.0,
                                        backgroundImage: MemoryImage(image),
                                      );
                                    }
                                  }
                                  return const CircleAvatar(
                                    radius: 20.0,
                                    child: Icon(Icons.person),
                                  );
                                }),
                            title: Text(contact.displayName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (contact.phones.isNotEmpty)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(contact.phones[0].number),
                                      ),
                                      Text(contact.phones[0].label),
                                    ],
                                  ),
                                if (contact.emails.isNotEmpty)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(contact.emails[0].address),
                                      ),
                                      Text(contact.emails[0].label),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          )),
    );
  }

  Future<List<Contact>?> getContacts() async {
    bool isGrantedPermission = await Permission.contacts.isGranted;
    if (!isGrantedPermission) {
      isGrantedPermission = await Permission.contacts.request().isGranted;
    }

    if (isGrantedPermission) {
      final contacts = await FastContacts.getAllContacts();

      return contacts;
    }

    return null;
  }
}
