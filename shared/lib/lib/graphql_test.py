# http://docs.mongoengine.org/apireference.html#fields
from mongoengine import connect
from mongoengine import Document
from mongoengine.fields import (
    ListField,
    StringField,
    IntField,
    FloatField,
    EmbeddedDocumentField,
    EmbeddedDocument
)

from graphene_mongo import MongoengineConnectionField, MongoengineObjectType
from graphene.relay import Node
import graphene

domain = "examon.lqzutab.mongodb.net"
user = 'examon_writer'
protocol = 'mongodb+srv'
password = 'b1DPMW4hQjVgbVKt'
uri = f"{protocol}://{user}:{password}@{domain}/?retryWrites=true&w=majority"

db_name = "graphene-mongo-example2"
connect(db_name, host=uri, alias="default")


class MetricsModel(EmbeddedDocument):
    categorised_difficulty = StringField()
    imports = ListField(StringField())
    calls = ListField(StringField())
    difficulty = FloatField()
    no_of_functions = IntField()
    loc = IntField()
    lloc = IntField()
    sloc = IntField()

    # counts
    arguments = IntField()
    importFromCount = IntField()
    expressionCount = IntField()
    classDefCount = IntField()
    returnCount = IntField()
    deleteCount = IntField()
    assignCount = IntField()
    augAssignCount = IntField()
    annAssignCount = IntField()
    forCount = IntField()
    asyncForCount = IntField()
    whileCount = IntField()
    ifCount = IntField()
    withCount = IntField()
    asyncWithCount = IntField()
    raiseCount = IntField()
    tryCount = IntField()
    assertCount = IntField()
    globalCount = IntField()
    nonlocalCount = IntField()
    exprCount = IntField()
    passCount = IntField()
    breakCount = IntField()
    continueCount = IntField()
    sliceCount = IntField()
    boolOpCount = IntField()
    binOpCount = IntField()
    unaryOpCount = IntField()
    lambdaCount = IntField()
    ifExpCount = IntField()
    dictCount = IntField()
    setCount = IntField()
    listCompCount = IntField()
    setCompCount = IntField()
    dictCompCount = IntField()
    generatorExpCount = IntField()
    awaitCount = IntField()
    yieldCount = IntField()
    yieldFromCount = IntField()
    compareCount = IntField()
    formattedValueCount = IntField()
    joinedStrCount = IntField()
    constantCount = IntField()
    attributeCount = IntField()
    subscriptCount = IntField()
    starredCount = IntField()
    nameCount = IntField()
    listCount = IntField()
    tupleCount = IntField()
    delCount = IntField()
    loadCount = IntField()
    storeCount = IntField()
    andCount = IntField()
    orCount = IntField()
    addCount = IntField()
    bitAndCount = IntField()
    bitOrCount = IntField()
    bitXorCount = IntField()
    divCount = IntField()
    floorDivCount = IntField()
    lShiftCount = IntField()
    modCount = IntField()
    multCount = IntField()
    matMultCount = IntField()
    powCount = IntField()
    rShiftCount = IntField()
    subCount = IntField()
    invertCount = IntField()
    notCount = IntField()
    uAddCount = IntField()
    uSubCount = IntField()
    eqCount = IntField()
    gtCount = IntField()
    gtECount = IntField()
    inCount = IntField()
    isCount = IntField()
    isNotCount = IntField()
    ltCount = IntField()
    ltECount = IntField()
    notEqCount = IntField()
    notInCount = IntField()
    comprehensionCount = IntField()
    exceptHandlerCount = IntField()
    argumentsCount = IntField()
    argCount = IntField()
    keywordCount = IntField()
    aliasCount = IntField()
    withitemCount = IntField()
    indexCount = IntField()
    suiteCount = IntField()
    augLoadCount = IntField()
    augStoreCount = IntField()
    paramCount = IntField()
    numCount = IntField()
    strCount = IntField()
    bytesCount = IntField()
    nameConstantCount = IntField()
    ellipsisCount = IntField()


class QuestionModel(Document):
    name = StringField()
    tags = ListField(StringField())
    unique_id = StringField()
    internal_id = StringField()
    function_src = StringField()
    repository = StringField()
    hints = ListField(StringField())
    print_logs = ListField(StringField())
    correct_answer = StringField()
    metrics = EmbeddedDocumentField(MetricsModel)


class Question(MongoengineObjectType):
    class Meta:
        collection = 'questions'
        model = QuestionModel
        interfaces = (Node,)
        filter_fields = {
            'name': ['exact', 'icontains', 'istartswith']
        }


class Metrics(MongoengineObjectType):
    class Meta:
        model = MetricsModel
        interfaces = (Node,)


def init_db():
    # Create the fixtures
    question = QuestionModel(
        name="Engineering",
        unique_id="unique_id",
        internal_id="internal_id",
        function_src="function_src",
        repository="repository",
        hints=["Engineering"],
        print_logs=['a'],
        tags=['a'],
        metrics=MetricsModel(
            no_of_functions=1,
            loc=8,
            lloc=7,
            sloc=7,
            difficulty=0.5,
            categorised_difficulty="Medium",
            imports=[],
            calls=["question1", "print"],
            isCount=9
        )
    )
    question.save()


init_db()


class Query(graphene.ObjectType):
    node = Node.Field()
    questions = MongoengineConnectionField(Question)


default_query = """
{
  questions {
    edges {
      node {
        id,
        name,
        uniqueId,
        internalId,
        tags, 
        metrics {
          noOfFunctions
          categorisedDifficulty
          isCount
        }
      }
    }
  }
}""".strip()

schema = graphene.Schema(query=Query, types=[Question])
result = schema.execute(default_query)
print(result)
