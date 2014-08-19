CREATE OR REPLACE  FUNCTION compare_vector (idRecodVov BIGINT, type_table BIGINT, val_vector double precision[], val_index INTEGER[], delta double precision)
RETURNS INTEGER[] AS
$BODY$
DECLARE
  --flag BOOLEAN;
  valueVectorIn double precision;
  valueVectorCur double precision;
  i integer;
  indexCompare integer;
  --row_vov_cur values_​​of_the_vectors%rowtype;
  result INTEGER[];
  id_document BIGINT;
  val_vector_cur double precision[];
BEGIN
  result[2] := type_table;
  IF array_upper(val_vector, 1) IS NULL THEN
     result[1] := -1;
     RETURN result; -- ошибка список значений векторов пуст
  END IF;

  IF array_upper(val_index, 1) IS NULL THEN
     result[1] := -2;
     RETURN result; -- ошибка список индексов пуст
  END IF;

  --flag = false;--выставляем флаг что данные вектора различны и нам не подходят

  IF type_table = 1 THEN
    SELECT values_​​of_the_vectors.id_document, values_​​of_the_vectors.val_vector INTO id_document, val_vector_cur FROM values_​​of_the_vectors WHERE id=idRecodVov;  -- получаем строку с которой будем сравнивать переданный вектор
  END IF;
  
  IF type_table = 2 THEN
    SELECT other_soursces.id_document, other_soursces.val_vector INTO id_document, val_vector_cur FROM other_soursces WHERE id=idRecodVov;  -- получаем строку с которой будем сравнивать переданный вектор
  END IF;
  --FOR id_document, val_vector_cur IN SELECT id_document, val_vector FROM values_​​of_the_vectors WHERE id=idRecodVov LOOP -- проход по все таблице
  --  
  --END LOOP;
  
  FOR i IN 1..array_upper(val_index, 1) LOOP
     indexCompare := val_index[i];
     valueVectorIn := val_vector[indexCompare];
     valueVectorCur := val_vector_cur[indexCompare];
     IF valueVectorIn IS NULL OR valueVectorCur IS NULL THEN
       result[1] := -3;
       RETURN result; -- ошибка значение индекса вышло за границу массивов
     END IF;

     IF abs(valueVectorIn - valueVectorCur) > delta THEN
       RETURN NULL;
     END IF;
     
     --RAISE NOTICE 'indexCompare % valueVectorIn % valueVectorCur %', indexCompare, valueVectorIn, valueVectorCur; --отладочная печать
  END LOOP;

  result[1] := id_document;
  RETURN result; 
END
$BODY$
LANGUAGE plpgsql;

--SELECT DISTINCT compare_vector(vov.id, vov.id_type_table, '{111, 222}', '{1}', 0.1) as s FROM values_​​of_the_vectors AS vov --limit 100 -- WHERE res IS NOT NULL 
SELECT DISTINCT result FROM values_​​of_the_vectors AS vov, compare_vector(vov.id, vov.id_type_table, '{111, 222}', '{1}', 0.1) as result WHERE result IS NOT NULL limit 100
