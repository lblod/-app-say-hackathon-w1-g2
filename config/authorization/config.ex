alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates
alias Acl.GraphSpec.Constraint.Resource.NoPredicates, as: NoPredicates
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup

defmodule Acl.UserGroups.Config do
  @public_type [
    "http://www.w3.org/ns/org#Role",
    "http://data.vlaanderen.be/ns/besluit#Bestuurseenheid",
    "http://xmlns.com/foaf/0.1/Person",
    "http://xmlns.com/foaf/0.1/OnlineAccount",
    "http://www.w3.org/2004/02/skos/core#Concept",
    "http://www.w3.org/ns/org#Organization",
    "http://www.w3.org/ns/org#Site",
    "http://schema.org/ContactPoint",
    "http://lblod.data.gift/vocabularies/organisatie/TypeVestiging",
    "http://lblod.data.gift/vocabularies/organisatie/BestuurseenheidClassificatieCode",
    "http://lblod.data.gift/vocabularies/organisatie/OrganisatieStatusCode",
    "http://www.w3.org/2004/02/skos/core#ConceptScheme",
    "http://publications.europa.eu/ontology/euvoc#Country",
    "http://www.w3.org/ns/prov#Location",
    "http://www.w3.org/ns/locn#Address",
    "https://id.erfgoed.net/vocab/ontology#Dossier",
    "https://id.erfgoed.net/vocab/ontology#LocatieElementPerceel",
    "https://id.erfgoed.net/vocab/ontology#Aanduidingsobject",
  ]

  @org_type []

  @shared_type []

  defp is_authenticated() do
    %AccessByQuery{
      vars: [],
      query: "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
        PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
        SELECT DISTINCT ?session_group ?session_role WHERE {
          <SESSION_ID> ext:sessionGroup/mu:uuid ?session_group;
                       ext:sessionRole ?session_role.
        }"
      }
  end

  def user_groups do
    [
      %GroupSpec {
        name: "shared",
        useage: [:write, :read_for_write],
        access: is_authenticated(),
        graphs: [
          %GraphSpec {
            graph: "http://mu.semte.ch/graphs/shared",
            constraint: %ResourceConstraint {
              resource_types: @shared_type
            }
          },
        ]
      },

      %GroupSpec {
        name: "org",
        useage: [:read, :write, :read_for_write],
        access: %AccessByQuery {
          vars: ["session_group"],
          query: "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
                  PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
                  SELECT DISTINCT ?session_group WHERE {
                    <SESSION_ID> ext:sessionGroup/mu:uuid ?session_group;
                                 ext:sessionRole \"Hackathon\".
                  }"
        },
        graphs: [
          %GraphSpec {
            graph: "http://mu.semte.ch/graphs/organizations/",
            constraint: %ResourceConstraint {
              resource_types: @org_type
            }
          },
        ]
      },

      %GroupSpec {
        name: "public",
        useage: [:read],
        access: %AlwaysAccessible{},
        graphs: [
          %GraphSpec {
            graph: "http://mu.semte.ch/graphs/public",
            constraint: %ResourceConstraint {
              resource_types: @public_type
            }
          },
          %GraphSpec {
            graph: "http://mu.semte.ch/graphs/shared",
            constraint: %ResourceConstraint {
              resource_types: @shared_type
            }
          }
        ]
      },


      %GraphCleanup {
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end
