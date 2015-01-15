#ui-export-to-csv
*TODO* tell me all about your element.


    Polymer 'ui-export-to-csv',

        downloadExcelCsv : (rows, attachmentFilename) ->
            blob = @makeExcelCsvBlob(rows)
            a = document.createElement('a')
            a.style.display = 'none'
            a.download = attachmentFilename
            document.body.appendChild(a)
            a.href = URL.createObjectURL(blob)
            a.click()
            URL.revokeObjectURL(a.href)
            a.remove()
            return

        makeExcelCsvBlob : (rows) ->
            new Blob([@asUtf16(@toTsv(rows)).buffer], {type: "text/csv;charset=UTF-8"})

        asUtf16 : (str) ->
            buffer = new ArrayBuffer(str.length * 2)
            bufferView = new Uint16Array(buffer)
            bufferView[0] = 0xfeff
            for i in [0..str.length]
                val = str.charCodeAt(i)
                bufferView[i + 1] = val
            bufferView

        toTsv : (rows) ->
            escapeValue = (val) ->
                if typeof val is 'string'
                    '"' + val.replace(/"/g, '""') + '"'
                else if val?
                    val
                else
                    ''
            rows.map((row) -> row.map(escapeValue).join('\t')).join('\n') + '\n'

        parseData: (str) ->
            "\"" + str.replace(/^\s\s*/, "").replace(/\s*\s$/, "").replace(/"/g, "\"\"") + "\""

        downloadCsv: ->
            data=[]
            header = []
            ignoreFields = []

            if @dataSrcId and @dataSrcAttr
                @data = document.querySelector('#'+@dataSrcId)?[@dataSrcAttr]

            if !@data
                return false

            @ignoreFields?.split(',').forEach (i) =>
                ignoreFields.push i.trim()

            Object.keys(@data[0]).forEach (i) =>
                if ignoreFields.indexOf(i) < 0
                    header.push i

            data.push(header)


            @data.forEach (i) =>
                dataobj = []
                for key, value of i
                    if ignoreFields.indexOf(key) < 0
                        dataobj.push value

                data.push(dataobj)

            @downloadExcelCsv(data, 'clientcontacts-list.csv')

